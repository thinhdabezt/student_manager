import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  // Chụp ảnh từ camera
  static Future<File?> takePhoto() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return null;

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return null;

    return _saveImage(File(pickedFile.path));
  }

  // Chọn ảnh từ thư viện
  static Future<File?> pickFromGallery() async {
    // For Android, we don't need to request permission for image_picker
    // as it uses the system picker which has its own permissions
    // For iOS, request photo library permission
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (!status.isGranted) return null;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    return _saveImage(File(pickedFile.path));
  }

  // Lưu ảnh vào thư mục app
  static Future<File> _saveImage(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final newPath = join(dir.path, basename(file.path));
    return file.copy(newPath);
  }
}
