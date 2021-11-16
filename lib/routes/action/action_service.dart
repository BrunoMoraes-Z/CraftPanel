import 'dart:convert';
import 'dart:io';

import 'package:craft_panel/common/addons/my_response.dart';
import 'package:craft_panel/common/constants.dart';
import 'package:craft_panel/common/files/config_file.dart';
import 'package:craft_panel/common/game/mine_server.dart';
import 'package:craft_panel/routes/server/server_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as path;
import '../../common/addons/response_addon.dart';

class ActionService {
  static Handler get route {
    var route = Router();

    // Visualizar o log do servidor
    route.get('/<serverId>/log', (Request request, String serverId) async {
      var validId = validator(serverId);
      if (validId != null) return validId;

      if (!gameLog!.running(serverId)) {
        return MyResponse().notFound(
          {
            'message': 'Server não esta ligado no momento.',
          },
        );
      }

      final server = gameLog!.servers[serverId];

      return MyResponse().ok(
        {
          'logs': server!.logs,
        },
      );
    });

    // ligar o servidor
    route.post('/<serverId>', (Request request, String serverId) async {
      var validId = validator(serverId);
      if (validId != null) return validId;

      if (gameLog!.running(serverId)) {
        return MyResponse().notFound(
          {
            'message': 'Server esta ligado.',
          },
        );
      }

      var serverDir = Directory.fromUri(
        Uri.directory(path.join(config.servers_dir, serverId)),
      );

      Map<String, dynamic> serverConfig = json.decode(
        File(path.join(serverDir.path, 'server.json')).readAsStringSync(),
      );

      final server = MineServer(
        id: serverConfig['server_id'],
        serverName: serverConfig['server_name'],
        serverPort: serverConfig['server_port'],
        provider: serverConfig['provider'],
        version: '',
        minRam: serverConfig['min_ram'],
        maxRam: serverConfig['max_ram'],
      );

      final result = await server.start();
      if (result != null) {
        return MyResponse().notFound(result);
      }

      return MyResponse().ok(
        {
          'message': 'Servidor ligado.',
        },
      );
    });

    // Executar comando no servidor
    route.post('/<serverId>/run', (Request request, String serverId) async {
      var validId = validator(serverId);
      if (validId != null) return validId;

      if (!gameLog!.running(serverId)) {
        return MyResponse().notFound(
          {
            'message': 'Server não esta ligado no momento.',
          },
        );
      }

      final body = await request.jsonBody();

      if (body.containsKey('command')) {
        final server = gameLog!.servers[serverId];
        await server!.run(body['command']);
        return MyResponse().ok(
          {
            'command': body['command'],
          },
        );
      } else {
        return MyResponse().notFound(
          {
            'message': 'body inválido.',
            'example': {
              'command': 'STRING',
            }
          },
        );
      }
    });

    // Desliga o servidor
    route.delete('/<serverId>', (Request request, String serverId) async {
      var validId = validator(serverId);
      if (validId != null) return validId;

      if (!gameLog!.running(serverId)) {
        return MyResponse().notFound(
          {
            'message': 'Server não esta ligado no momento.',
          },
        );
      }

      final server = gameLog!.servers[serverId];

      final result = await server!.stop();

      if (result != null) {
        return MyResponse().notFound(result);
      }

      return MyResponse().ok(
        {
          'message': 'Servidor desligado.',
        },
      );
    });

    // Desliga o servidor
    route.post('/<serverId>/kill', (Request request, String serverId) async {
      var validId = validator(serverId);
      if (validId != null) return validId;

      if (!gameLog!.running(serverId)) {
        return MyResponse().notFound(
          {
            'message': 'Server não esta ligado no momento.',
          },
        );
      }

      final server = gameLog!.servers[serverId];
      await server!.kill();

      return MyResponse().ok(
        {
          'message': 'Servidor desligado.',
        },
      );
    });

    return route;
  }
}
