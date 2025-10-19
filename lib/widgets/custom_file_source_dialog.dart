import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

enum FileSourceType { camera, gallery, file }

typedef FilePickedCallback = void Function(File file, String fileName);

class CustomFileSourceDialog {
  static final ImagePicker _picker = ImagePicker();

  static Future<void> show({
    required BuildContext context,
    required FilePickedCallback onPicked,
    List<FileSourceType> allowedSources = const [
      FileSourceType.camera,
      FileSourceType.gallery,
      FileSourceType.file,
    ],
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('Pilih Sumber File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (allowedSources.contains(FileSourceType.camera))
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Kamera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      onPicked(File(pickedFile.path), pickedFile.name);
                    }
                  },
                ),
              if (allowedSources.contains(FileSourceType.camera))
                const Divider(),
              if (allowedSources.contains(FileSourceType.gallery))
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      onPicked(File(pickedFile.path), pickedFile.name);
                    }
                  },
                ),
              if (allowedSources.contains(FileSourceType.gallery))
                const Divider(),
              if (allowedSources.contains(FileSourceType.file))
                ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: const Text('File (PDF/DOC)'),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx'],
                    );
                    if (result != null && result.files.single.path != null) {
                      onPicked(File(result.files.single.path!),
                          result.files.single.name);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
