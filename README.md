# lectureswtimecodes

Phone app that turns a lecture into a list of topics. Tap a topic and the player jumps there.

Open the folder in Android Studio and run it on a phone or emulator.

The three lectures already in the list are sample data and have no audio. Record saves the microphone audio and plays it back. Open file copies the chosen audio into the app and plays it. Lectures you add are saved on the phone.

After a recording or an opened file, the app listens to the audio on the phone and splits it into topics. Tap a topic to jump there. The first time, it downloads a small speech model, so the phone needs a network connection once.

To put it on an iPhone, open the `ios` folder in Xcode, pick your phone, and run.
