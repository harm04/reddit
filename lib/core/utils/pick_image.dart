import 'package:file_picker/file_picker.dart';

Future<FilePickerResult?> pickImage() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
  );
  return result;
}