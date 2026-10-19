package com.vanya630.lectureswtimecodes

import android.media.MediaCodec
import android.util.Log
import android.media.MediaExtractor
import android.media.MediaFormat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "toWav") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                if (path.isNullOrEmpty()) {
                    result.error("audio", "Missing audio path", null)
                    return@setMethodCallHandler
                }
                Thread {
                    try {
                        val wav = AudioToWav().convert(path)
                        runOnUiThread { result.success(wav) }
                    } catch (error: Exception) {
                        runOnUiThread { result.error("audio", error.message, null) }
                    }
                }.start()
            }
    }

    companion object {
        private const val CHANNEL = "com.vanya630.lectureswtimecodes/audio"
    }
}

private class AudioToWav {
    fun convert(path: String): String {
        val input = File(path)
        if (!input.exists()) throw IllegalArgumentException("Audio file is missing")
        val output = File(input.parentFile, "speech_${System.currentTimeMillis()}.wav")
        val extractor = MediaExtractor()
        extractor.setDataSource(path)
        val track = (0 until extractor.trackCount).firstOrNull { index ->
            val mime = extractor.getTrackFormat(index).getString(MediaFormat.KEY_MIME) ?: ""
            mime.startsWith("audio/")
        } ?: throw IllegalArgumentException("No audio in this file")
        extractor.selectTrack(track)
        val format = extractor.getTrackFormat(track)
        val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
        val writer = if (mime == "audio/raw") {
            writePcm(extractor, format, output)
            return output.absolutePath
        } else {
            decode(extractor, format, output)
        }
        extractor.release()
        return writer
    }

    private fun writePcm(extractor: MediaExtractor, format: MediaFormat, output: File): String {
        val rate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        val writer = Wav16kWriter(output, rate)
        val buffer = ByteBuffer.allocate(64 * 1024)
        while (true) {
            buffer.clear()
            val size = extractor.readSampleData(buffer, 0)
            if (size < 0) break
            val chunk = ByteArray(size)
            buffer.position(0)
            buffer.limit(size)
            buffer.get(chunk)
            writer.feed(chunk, channels)
            extractor.advance()
        }
        extractor.release()
        writer.close()
        Log.i("Lectures", "wav ${output.length()} bytes from raw at $rate Hz")
        return output.absolutePath
    }

    private fun decode(extractor: MediaExtractor, format: MediaFormat, output: File): String {
        val mime = format.getString(MediaFormat.KEY_MIME)!!
        val codec = MediaCodec.createDecoderByType(mime)
        codec.configure(format, null, null, 0)
        codec.start()
        var rate = if (format.containsKey(MediaFormat.KEY_SAMPLE_RATE)) format.getInteger(MediaFormat.KEY_SAMPLE_RATE) else 44100
        var channels = if (format.containsKey(MediaFormat.KEY_CHANNEL_COUNT)) format.getInteger(MediaFormat.KEY_CHANNEL_COUNT) else 1
        val writer = Wav16kWriter(output, rate)
        val info = MediaCodec.BufferInfo()
        var inputDone = false
        var outputDone = false
        var stalls = 0
        while (!outputDone && stalls < 200) {
            if (!inputDone) {
                val inIndex = codec.dequeueInputBuffer(10_000)
                if (inIndex >= 0) {
                    val buffer = codec.getInputBuffer(inIndex)!!
                    val size = extractor.readSampleData(buffer, 0)
                    if (size < 0) {
                        codec.queueInputBuffer(inIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                        inputDone = true
                    } else {
                        codec.queueInputBuffer(inIndex, 0, size, extractor.sampleTime, 0)
                        extractor.advance()
                    }
                }
            }
            when (val outIndex = codec.dequeueOutputBuffer(info, 10_000)) {
                MediaCodec.INFO_TRY_AGAIN_LATER -> stalls += 1
                MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    val changed = codec.outputFormat
                    rate = changed.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                    channels = changed.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                    writer.useSampleRate(rate)
                    stalls = 0
                }
                else -> {
                    if (outIndex >= 0) {
                        val buffer = codec.getOutputBuffer(outIndex)
                        if (buffer != null && info.size > 0) {
                            val chunk = ByteArray(info.size)
                            buffer.position(info.offset)
                            buffer.limit(info.offset + info.size)
                            buffer.get(chunk)
                            writer.feed(chunk, channels)
                        }
                        codec.releaseOutputBuffer(outIndex, false)
                        stalls = 0
                        if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) outputDone = true
                    }
                }
            }
        }
        codec.stop()
        codec.release()
        writer.close()
        Log.i("Lectures", "wav ${output.length()} bytes from $mime at $rate Hz")
        if (writer.samples == 0) throw IllegalArgumentException("Could not read this audio file")
        return output.absolutePath
    }
}

private class Wav16kWriter(private val file: File, var sampleRate: Int) {
    private val stream = FileOutputStream(file)
    private var index = 0.0
    private var count = 0
    var samples = 0
        private set

    init {
        stream.write(ByteArray(44))
    }

    fun useSampleRate(rate: Int) {
        if (count == 0) sampleRate = rate
    }

    fun feed(interleaved: ByteArray, channels: Int) {
        if (channels <= 0 || interleaved.size < 2) return
        val shorts = interleaved.size / 2
        val frames = shorts / channels
        if (frames <= 0) return
        val mono = ShortArray(frames)
        val view = ByteBuffer.wrap(interleaved).order(ByteOrder.LITTLE_ENDIAN)
        for (frame in 0 until frames) {
            var sum = 0
            for (channel in 0 until channels) {
                sum += view.short.toInt()
            }
            mono[frame] = (sum / channels).toShort()
        }
        val start = count
        val end = count + mono.size
        val ratio = sampleRate.toDouble() / 16000.0
        val out = ByteBuffer.allocate(mono.size * 2).order(ByteOrder.LITTLE_ENDIAN)
        var wrote = 0
        while (index + 1 < end) {
            val local = (index - start).toInt()
            if (local < 0 || local + 1 >= mono.size) break
            val frac = index - start - local
            val mixed = mono[local] * (1.0 - frac) + mono[local + 1] * frac
            out.putShort(mixed.toInt().coerceIn(-32768, 32767).toShort())
            wrote += 1
            index += ratio
        }
        count = end
        if (wrote == 0) return
        val bytes = ByteArray(wrote * 2)
        out.position(0)
        out.get(bytes)
        stream.write(bytes)
        samples += wrote
    }

    fun close() {
        val dataSize = samples * 2
        val header = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN)
        header.put("RIFF".toByteArray(Charsets.US_ASCII))
        header.putInt(36 + dataSize)
        header.put("WAVE".toByteArray(Charsets.US_ASCII))
        header.put("fmt ".toByteArray(Charsets.US_ASCII))
        header.putInt(16)
        header.putShort(1)
        header.putShort(1)
        header.putInt(16000)
        header.putInt(32000)
        header.putShort(2)
        header.putShort(16)
        header.put("data".toByteArray(Charsets.US_ASCII))
        header.putInt(dataSize)
        stream.flush()
        stream.close()
        RandomAccessFile(file, "rw").use { raf ->
            raf.seek(0)
            raf.write(header.array())
        }
    }
}
