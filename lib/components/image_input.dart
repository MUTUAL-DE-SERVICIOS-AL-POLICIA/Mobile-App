import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/model/files_model.dart';

class ImageInput extends StatefulWidget {
  final double sizeImage;
  final Function(InputImage, File) onPressed;
  final FileDocument itemFile;
  const ImageInput(
      {super.key,
      required this.sizeImage,
      required this.onPressed,
      required this.itemFile});

  @override
  ImageInputState createState() => ImageInputState();
}

class ImageInputState extends State<ImageInput> {
  final ImagePicker _picker = ImagePicker();
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
                                    gaplessPlayback: true,
                                  ))),
                    Positioned(
                        bottom: 2,
                        right: 0,
                        child: IconBtnComponent(
                            iconSize: 20.w,
                            iconText: 'assets/icons/camera.svg',
                            onPressed: () => _displayPickImageDialog()))
                  ],
                ),
              ),
              if (!widget.itemFile.validateState)
                Flexible(child: Text(widget.itemFile.textValidate!)),
            ]))));
  }

  _onImageButtonPressed(ImageSource source, BuildContext context) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 540,
      maxHeight: 380,
      imageQuality: 100,
    );
    if (!mounted) return;
    Navigator.pop(context);
    if (pickedFile == null) return;
    final inputImage = InputImage.fromFilePath(pickedFile.path);
    final file = File(pickedFile.path);
    return widget.onPressed(inputImage, file);
  }

  _displayPickImageDialog() {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
              title: const Text(
                'Seleccionar medio de Imagen',
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: const Text('Cámara'),
                  onPressed: () =>
                      _onImageButtonPressed(ImageSource.camera, context),
                ),
                CupertinoActionSheetAction(
                  child: const Text('Galería'),
                  onPressed: () =>
                      _onImageButtonPressed(ImageSource.gallery, context),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop("Discard");
                },
              ));
        });
  }
}
