import 'dart:convert' as convert;

import 'package:shelf/shelf.dart';

extension RequestAddon on Request {
  Future<Map<String, dynamic>> jsonBody() async {
    var raw = await readAsString();
    return convert.json.decode(raw.isEmpty ? '{}' : raw);
  }
}
