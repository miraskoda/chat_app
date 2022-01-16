import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as pick;
import 'dart:io';
import 'package:path/path.dart';

class ImagePicker extends StatefulWidget {
  final Function imagePicker;

  ImagePicker(this.imagePicker);

  @override
  _ImagePickerState createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePicker> {
  late File pickedImageFile = File("");

  void _pickImage() async {
    final picker = pick.ImagePicker();
    final pickedImage = await picker.getImage(
      source: pick.ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    pickedImageFile = File(pickedImage!.path);
    print("picked:" + pickedImageFile.toString());

    setState(() {});

    widget.imagePicker(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    print(pickedImageFile.path);
    return Column(
      children: [
        //need to reapair image loading
        CircleAvatar(
          backgroundImage: pickedImageFile.path.isEmpty
              ? AssetImage('lib/images/user.png') as ImageProvider
              : FileImage(pickedImageFile),
          radius: 50,
        ),
        FlatButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.camera),
            label: Text("Take a photo")),
      ],
    );
  }
}
