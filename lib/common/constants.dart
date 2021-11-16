import 'dart:io';

import 'package:craft_panel/common/files/config_file.dart';
import 'package:craft_panel/common/game/game_log.dart';

late GameLog? gameLog;

final secret = config.JWTSecret;

final sysDir = Directory.fromUri(Uri.parse(Platform.script.path)).parent;
