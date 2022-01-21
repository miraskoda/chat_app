import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as pick;
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImagePicker extends StatefulWidget {
  final Function imagePicker;
  final bool isOnLoginPage;

  ImagePicker(this.imagePicker, this.isOnLoginPage);

  @override
  _ImagePickerState createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  late File pickedImageFile = File("");

  Future<String> getImage() async {
    final userData = FirebaseStorage.instance
        .ref()
        .child("user_images")
        .child(FirebaseAuth.instance.currentUser!.uid + ".jpg");
    return await userData.getDownloadURL();
  }

  void _pickImage() async {
    try {
      final picker = pick.ImagePicker();
      final pickedImage = await picker.getImage(
        source: pick.ImageSource.camera,
        imageQuality: 50,
        maxWidth: 150,
      );
      pickedImageFile = File(pickedImage!.path);

      print("picked:" + pickedImageFile.toString());

      widget.imagePicker(pickedImageFile);

      if (!widget.isOnLoginPage) {
        //put file to storage
        final dwnlLing = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child(FirebaseAuth.instance.currentUser!.uid + ".jpg");
        await dwnlLing.putFile(pickedImageFile);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({"image_url": await dwnlLing.getDownloadURL()});
        //change reference in DB
      }
    } catch (e) {
      throw e;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: widget.isOnLoginPage
          ? CircleAvatar(
              backgroundImage: pickedImageFile.path.isEmpty
                  ? const AssetImage('lib/images/user.png') as ImageProvider
                  : FileImage(pickedImageFile),
              radius: 50,
              child: Text(AppLocalizations.of(context)!.takePhoto),
            )
          : FutureBuilder(
              future: getImage(),
              builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
                return snapshot.connectionState == ConnectionState.done
                    ? CircleAvatar(
                        backgroundImage: pickedImageFile.path.isEmpty
                            ? NetworkImage(snapshot.data as String)
                                as ImageProvider
                            : FileImage(pickedImageFile),
                        radius: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 70.0),
                          child: Text(AppLocalizations.of(context)!.takePhoto),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      );
              },
            ),
    );
  }
}
