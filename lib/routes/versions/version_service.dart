import 'dart:convert';

import 'package:craft_panel/common/addons/my_response.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

class VersionService {
  static Handler get route {
    var route = Router();

    route.get('/', (Request request) async {
      var paperUrl = 'https://serverjars.com/api/fetchAll/paper';

      var message = {
        'paper': [],
        'mohist': [
          '1.16.5',
          '1.12.2',
        ]
      };

      var response = await http.get(Uri.parse(paperUrl));
      Map<String, dynamic> version_manifest = json.decode(response.body);
      var versions = version_manifest['response'] as List;
      if (versions.isNotEmpty) {
        for (Map<String, dynamic> value in versions) {
          message['paper']!.add(value['version']);
        }
      }

      message['paper']!.sort();

      return MyResponse().ok(message);
    });

    return route;
  }
}
