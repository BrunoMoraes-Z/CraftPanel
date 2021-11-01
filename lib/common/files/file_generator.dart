import 'dart:convert';
import 'dart:io';

import 'package:craft_panel/common/constants.dart';

class FileConfig {
  final String fileName;
  late dynamic content;
  late File _file;

  FileConfig({
    required this.fileName,
    required this.content,
  }) {
    _file = File.fromUri(
      Uri.file('${sysDir.path}${Platform.pathSeparator}${fileName}'),
    );
    if (!exist) {
      _file.createSync();
      _file.writeAsStringSync(json.encode(this.content));
    } else {
      this.content = json.decode(_file.readAsStringSync());
    }
  }

  bool get exist => _file.existsSync();
}
