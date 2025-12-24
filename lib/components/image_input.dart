import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:file_selector/file_selector.dart';

import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/model/files_model.dart';

class ImageInput extends StatefulWidget {
  final double sizeImage;
  final Function(InputImage, File) onPressed;
  final FileDocument itemFile;

  const ImageInput({
    super.key,
    required this.sizeImage,
    required this.onPressed,
    required this.itemFile,
  });

  @override
  ImageInputState createState() => ImageInputState();
}

class ImageInputState extends State<ImageInput> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _displayPickImageDialog(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: widget.itemFile.imageFile == null
                            ? Image.asset(
                                widget.itemFile.imagePathDefault!,
                                gaplessPlayback: true,
                                width: widget.sizeImage,
                                height: widget.sizeImage,
                              )
                            : Image.file(
                                widget.itemFile.imageFile!,
                                fit: BoxFit.cover,
                                width: widget.sizeImage,
                                height: widget.sizeImage,
                                gaplessPlayback: true,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 0,
                      child: IconBtnComponent(
                        iconSize: 20.w,
                        iconText: 'assets/icons/camera.svg',
                        onPressed: () => _displayPickImageDialog(),
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.itemFile.validateState)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(widget.itemFile.textValidate!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png'],
    );

    final XFile? file = await openFile(
      acceptedTypeGroups: [typeGroup],
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (file == null) return;

    final inputImage = InputImage.fromFilePath(file.path);
    final imageFile = File(file.path);

    widget.onPressed(inputImage, imageFile);
  }

  void _displayPickImageDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Seleccionar imagen'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: const Text('Galería'),
              onPressed: () => _pickImageFromGallery(context),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        );
      },
    );
  }
}
