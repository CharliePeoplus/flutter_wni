import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImagePickerManager {
  late ImageSource type;
  late ImagePicker _picker = ImagePicker();
  
  Future<Uint8List?> present() async {
    
    final imageFile = await _picker.pickImage(
      source: type,
      maxWidth: 600,
      imageQuality: 20
    );

    if (imageFile != null) {
      File result = File(imageFile.path);
      return await result.readAsBytes();
    }

    // ignore: avoid_print
    print('No image selected.');
    return null;
  }

  static ImageSource getSource(String type) {
    var source = ImageSource.camera;

    switch (type) {
      case "0":
      case "camera":
        source = ImageSource.camera;
        break; 

      case "1":
      case "gallery":
        source = ImageSource.gallery;
        break; 

      default:
        //
        break;
    }

    return source;
  }
  
}