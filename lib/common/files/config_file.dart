import 'dart:io';

import 'package:craft_panel/common/files/file_generator.dart';
import 'package:craft_panel/models/config.dart';

Config? _config;

Config get config => _config!;

Future<bool> loadConfig() async {
  var fg = FileConfig(
    fileName: 'config.json',
    content: {
      'jwt_secret': '',
      'servers_dir': '',
      'dns': ''
    },
  );

  _config = Config.fromJson(fg.content);

  if (config.JWTSecret.isEmpty) {
    print('Configure um token para JWT.');
    return false;
  }

  if (config.servers_dir.isEmpty) {
    print('Configure o diretório dos servidores.');
    return false;
  } else {
    if (!await Directory.fromUri(Uri.directory(config.servers_dir)).exists()) {
      print('Configure um diretório dos servidores válido.');
      return false;
    }
  }

  return true;
}
