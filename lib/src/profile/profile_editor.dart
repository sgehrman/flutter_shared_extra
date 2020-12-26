import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:flutter_shared_extra/flutter_shared_extra.dart';

class EditProfileDialog extends StatefulWidget {
  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final ProfileData _data = ProfileData();
  final _formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  Future<void> handleImagePicker({@required bool camera}) async {
    final PickedFile file = await ImagePicker()
        .getImage(source: camera ? ImageSource.camera : ImageSource.gallery);

    if (file != null) {
      final Uint8List imageData = await file.readAsBytes();
      if (imageData != null) {
        final imageId = Utils.uniqueFirestoreId();

        final url = await ImageUrlUtils.uploadImageDataReturnUrl(
            imageId, imageData,
            folder: ImageUrlUtils.chatImageFolder);

        _data.photoUrl = url;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<FirebaseUserProvider>(context);

    return SimpleDialog(
      title: Text(
        'Edit your Information',
        style: Theme.of(context).textTheme.headline5,
      ),
      contentPadding:
          const EdgeInsets.only(top: 12, bottom: 16, left: 16, right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                initialValue: userProvider.displayName,
                // The validator receives the text that the user has entered.
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter your name';
                  }

                  return null;
                },
                onSaved: (String value) {
                  _data.name = value.trim();
                },
              ),
              TextFormField(
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                initialValue: userProvider.email,
                keyboardType: TextInputType
                    .emailAddress, // Use email input type for emails.

                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'Email Address',
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (StrUtils.isEmailValid(value)) {
                    return null;
                  }

                  return 'Please enter your email address';
                },
                onSaved: (String value) {
                  _data.email = value.trim();
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => handleImagePicker(camera: true),
              icon: const Icon(
                Icons.photo_camera,
              ),
            ),
            IconButton(
              onPressed: () => handleImagePicker(camera: false),
              icon: const Icon(
                Icons.photo,
              ),
            ),
          ],
        ),
        Text(_data.photoUrl ?? userProvider.photoUrl ?? ''),
        const SizedBox(
          height: 20,
        ),
        ThemeButton(
          title: 'Save',
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();

              Navigator.of(context).pop(_data);
            } else {
              setState(() {
                _autovalidate = true;
              });
            }
          },
        ),
      ],
    );
  }
}

Future<ProfileData> showEmailEditProfileDialog(BuildContext context) async {
  return showDialog<ProfileData>(
    context: context,
    builder: (BuildContext context) {
      return EditProfileDialog();
    },
  );
}

class ProfileData {
  String email = '';
  String name = '';
  String photoUrl;

  @override
  String toString() {
    return '$email $name';
  }
}