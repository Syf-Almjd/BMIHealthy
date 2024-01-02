import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

double getHeight(int percent, context) {
  return (MediaQuery.of(context).size.height * (percent / 100)).toDouble();
}

SizedBox getCube(int percent, context) {
  return SizedBox(
    width: (MediaQuery.of(context).size.width * (percent / 100)).toDouble(),
    height: (MediaQuery.of(context).size.height * (percent / 100)).toDouble(),
  );
}

double getWidth(int percent, context) {
  return (MediaQuery.of(context).size.width * (percent / 100)).toDouble();
}

Widget padBox({size}) {
  return Padding(padding: EdgeInsets.all(size ?? 10));
}

///shows logo
Padding logoContainer(context) {
  return Padding(
    padding: const EdgeInsets.all(50.0),
    child: Container(
        width: getWidth(50, context),
        height: getHeight(20, context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(width: 2),
        ),
        child: const Icon(Icons.person)),

    // child: const Image(
    //   image: AssetImage(Assets.assetsLogoTransparent),
    //   fit: BoxFit.contain,
    // ),
    // ),
  );
}

///For photo selection

///For photo selection
Widget chooseFile(context) {
  return Container(
    decoration: const BoxDecoration(
        color: Colors.amberAccent,
        borderRadius: BorderRadius.all(Radius.circular(20))),
    child: Stack(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: const Icon(Icons.person)),
        // child: const Image(
        //   image: AssetImage(Assets.assetsProfilePicture),
        //   fit: BoxFit.fill,
        // )),
        Positioned(
          bottom: 25,
          right: 25,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.black12),
            child: const Icon(
              Icons.mode_edit_outline_outlined,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}

///For photo preview
Widget fileChosen(fileUser, context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.memory(fileUser),
    ],
  );
}

//Show a toast
void showToast(String text, context) => toastification.show(
      context: context,
      title: text,
      alignment: Alignment.topCenter,
      primaryColor: Colors.green,
      autoCloseDuration: const Duration(seconds: 2),
    );

//Validate Text field
validateForm(
  GlobalKey<FormState> validateKey,
) {
  if (validateKey.currentState!.validate()) {
    validateKey.currentState!.save();
    return true;
  } else {
    return false;
  }
}

void openUrl(String url) {
  var openUrl = Uri.parse(url);
  launchUrl(
    openUrl,
    mode: LaunchMode.externalApplication,
  );
}

Future showChoiceDialog(
    {required BuildContext context,
    String? title,
    String? content,
    required Function onYes,
    Function? onNo}) {
  return (showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? ""),
          titleTextStyle: const TextStyle(fontSize: 20),
          content: Text(content ?? "هل أنت متأكد؟"),
          actions: [
            TextButton(
              child: const Text('لا'),
              onPressed: () {
                if (onNo != null) {
                  onNo();
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('نعم'),
              onPressed: () {
                onYes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }));
}
