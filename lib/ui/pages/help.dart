import 'package:flutter/material.dart';
import 'package:masami/ui/widgets/padded_text.dart';
import 'package:masami/utils/constants.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key, required this.title});

  final String title;

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const Text(
                  "How To Install Mods",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "Installing mods in MAS on Android should be simple and fast! And that is my goal!"
                  " Now, let's get started.",
                ),

                // --- STEP 1 ---
                const PaddedText(
                  "Step 1 - Selecting the APK",
                  style: TextStyle(fontSize: 20),
                ),
                Image.asset("$pathToStepsImages/step_1/step_1.png"),
                const PaddedText(
                  "The first step is simple, make sure to download the MAS on Android APK from Discord or Telegram."
                  " After you downloaded the APK, click the \"Select MAS APK File\" and select the APK file. It will"
                  " usually be in your Downloads folder.",
                ),
                Image.asset("$pathToStepsImages/step_1/open_from.png"),
                const PaddedText(
                  "Then select the apk (in this case MonikaAfterStoryv0.12.5.1.apk, yours may have a"
                  " different name)",
                ),
                Image.asset("$pathToStepsImages/step_1/downloads_folder.png"),
                const PaddedText(
                  "After selecting the apk file, you can click the next button.",
                ),

                // --- STEP 2 ---
                const PaddedText(
                  "Step 2 - Selecting the MODS",
                  style: TextStyle(fontSize: 20),
                ),
                Image.asset("$pathToStepsImages/step_2/step_2.png"),
                const PaddedText(
                  "You should be able to downloads mods from the Discord and Telegram mentioned earlier."
                  " The steps here are just as simple as the previous one, just press \"Select Mod Files\", "
                  "if you downloaded the mods, they'll usually be somewhere in your downloads folder.",
                ),
                Image.asset("$pathToStepsImages/step_2/downloads_folder.png"),
                const PaddedText(
                  "In this case I have 2 mods, all mods has to be in .zip files! You can now select the "
                  "mods you want to add by tap and holding one until its highlighted (to enter select mode) "
                  "and then selecting the rest.",
                ),
                Image.asset(
                  "$pathToStepsImages/step_2/selected_block_view.png",
                ),
                const PaddedText(
                  "You might be in list view mode, so yours would then look like this:",
                ),
                Image.asset(
                  "$pathToStepsImages/step_2/selected_list_view.png",
                ),
                const PaddedText(
                  "Now just click the \"OPEN\" button and then the \"Next\" button",
                ),

                // --- STEP 3 ---
                const PaddedText(
                  "Step 3 - Adding the MODS",
                  style: TextStyle(fontSize: 20),
                ),
                Image.asset("$pathToStepsImages/step_3/step_3.png"),
                const PaddedText(
                  "This is the easiest part! Just review what you have chosen, and if "
                  "you're happy, press \"Add Mods\". This will take a while to do, don't panic "
                  "if the progress bar is not moving, it's just busy doing it's thing.",
                ),
                Image.asset("$pathToStepsImages/step_3/extracting_apk.png"),
                const PaddedText(
                  "PLEASE NOTE: Do not close the app during this process!\n"
                  "\nAfter this step has been completed, you can press \"Next\"",
                ),
                Image.asset("$pathToStepsImages/step_3/done.png"),

                // --- STEP 4 ---
                const PaddedText(
                  "Step 4 - Signing the APK",
                  style: TextStyle(fontSize: 20),
                ),
                const PaddedText(
                  "To sign the APK, you need to get ZipSigner. You can either find it on Google or get it from the Telegram bot"
                  ". You'll get it along with the MAS game, by selecting the /zip_signer option. Just download and install the apk",
                ),
                // --- STEP 5 ---
                const PaddedText(
                  "Step 5 - Backup MAS",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
