import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LectureAudio") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "com.vanya630.lectureswtimecodes/audio",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "toWav",
            let args = call.arguments as? [String: Any],
            let path = args["path"] as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let wav = try AudioToWav.convert(path)
          DispatchQueue.main.async { result(wav) }
        } catch {
          DispatchQueue.main.async { result(FlutterError(code: "audio", message: error.localizedDescription, details: nil)) }
        }
      }
    }
  }
}

enum AudioToWav {
  static func convert(_ path: String) throws -> String {
    let inputUrl = URL(fileURLWithPath: path)
    let input = try AVAudioFile(forReading: inputUrl)
    guard let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: true) else {
      throw NSError(domain: "Lectures", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not read this audio file"])
    }
    let outputUrl = inputUrl.deletingLastPathComponent().appendingPathComponent("speech_\(Int(Date().timeIntervalSince1970 * 1000)).wav")
    let output = try AVAudioFile(forWriting: outputUrl, settings: format.settings, commonFormat: .pcmFormatInt16, interleaved: true)
    guard let converter = AVAudioConverter(from: input.processingFormat, to: format) else {
      throw NSError(domain: "Lectures", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not read this audio file"])
    }
    let capacity = AVAudioFrameCount(4096)
    var done = false
    while !done {
      guard let source = AVAudioPCMBuffer(pcmFormat: input.processingFormat, frameCapacity: capacity) else { break }
      try input.read(into: source)
      if source.frameLength == 0 {
        done = true
      }
      let ratio = 16000.0 / input.processingFormat.sampleRate
      let outCapacity = AVAudioFrameCount(Double(max(source.frameLength, 1)) * ratio) + 32
      guard let converted = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: outCapacity) else { break }
      var error: NSError?
      var supplied = false
      converter.convert(to: converted, error: &error) { _, status in
        if supplied || source.frameLength == 0 {
          status.pointee = .endOfStream
          return nil
        }
        supplied = true
        status.pointee = .haveData
        return source
      }
      if let error { throw error }
      if converted.frameLength > 0 {
        try output.write(from: converted)
      }
      if source.frameLength == 0 { done = true }
    }
    return outputUrl.path
  }
}
