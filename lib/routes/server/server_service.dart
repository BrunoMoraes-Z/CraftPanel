import 'dart:convert';
import 'dart:io';

import 'package:craft_panel/common/addons/my_response.dart';
import 'package:craft_panel/common/files/config_file.dart';
import 'package:craft_panel/common/game/mine_server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../../common/addons/response_addon.dart';
import 'package:path/path.dart' as path;

class ServerService {
  static Handler get route {
    var route = Router();

    // Criar um novo servidor.
    route.post('/create', (Request request) async {
      Map<String, dynamic> body = await request.jsonBody();

      var isNotValidBody =
          _properties.where((element) => !body.containsKey(element)).isNotEmpty;

      if (isNotValidBody) {
        return MyResponse().notFound({
          'message': 'Body invalido',
          'example': {
            'server_name': 'STRING',
            'server_port': 'INT',
            'server_version': 'STRING',
            'provider': 'STRING',
          }
        });
      }

      var server = MineServer(
        serverName: body['server_name'],
        serverPort: body['server_port'],
        version: body['server_version'],
        provider: body['provider'],
        minRam: 512,
        maxRam: 2048,
      );

      await server.mountServer();

      return MyResponse().ok(server.serverInfo());
    });

    // Recuperar configuração do servidor.
    route.get('/<serverId>', (Request request, String serverId) async {
      var validId = validator(serverId);
      if (validId != null) return validId;

      var serverDir = Directory.fromUri(
        Uri.directory(path.join(config.servers_dir, serverId)),
      );

      Map<String, dynamic> serverConfig = json.decode(
        File(path.join(serverDir.path, 'server.json')).readAsStringSync(),
      );

      return MyResponse().ok(serverConfig);
    });

    // Notificar utilização do enpoint.
    route.put('/', (Request request) async {
      return MyResponse().notFound(
        {
          'message': 'Request inválido.',
          'example': {
            'url': '/server/<serverId>',
            'body': {
              'server_name': 'STRING',
              'max_ram': 'INT',
            }
          }
        },
      );
    });

    // Listar servidores Disponiveis
    route.get('/', (Request request) async {
      final dir = Directory(config.servers_dir);
      final folders = await dir.list().toList();
      if (folders.isEmpty) {
        return MyResponse().notFound(
          {
            'message': 'Nenhum servidor criado ainda.',
          },
        );
      } else {
        final svs = [];
        folders.forEach((element) {
          Map<String, dynamic> content = json.decode(
            File(
              path.join(
                element.path,
                'server.json',
              ),
            ).readAsStringSync(),
          );

          svs.add(
            {
              "server_id": content['server_id'],
              "server_name": content['server_name'],
            },
          );
        });
        return MyResponse().ok(
          {
            'amount': svs.length,
            'servers': svs,
          },
        );
      }
    });

    // Realizar alterações nas configurações do servidor
    route.put('/<serverId>', (Request request, String serverId) async {
      var validId = validator(serverId);
      if (validId != null) return validId;

      var serverDir = Directory.fromUri(
        Uri.directory(path.join(config.servers_dir, serverId)),
      );

      final body = await request.jsonBody();

      if (body.isEmpty) {
        return MyResponse().notFound(
          {
            'message': 'Nenhuma alteração encontrada.',
          },
        );
      }

      Map<String, dynamic> serverConfig = json.decode(
        File(path.join(serverDir.path, 'server.json')).readAsStringSync(),
      );

      var errors = [];

      // Type Validator
      body.forEach((key, value) {
        key = key.toLowerCase();
        if (serverConfig.containsKey(key)) {
          if (key != 'path' && key != 'server_id') {
            if ((serverConfig[key] is int && !(value is int)) ||
                !(serverConfig[key] is int) && (value is int)) {
              errors.add(
                {
                  'message':
                      '$key é do tipo [${serverConfig[key].runtimeType}] e o valor informado é do tipo [${value.runtimeType}]'
                },
              );
            } else {
              if ((serverConfig[key] is String && !(value is String)) ||
                  !(serverConfig[key] is String) && (value is String)) {
                errors.add(
                  {
                    'message':
                        '$key é do tipo [${serverConfig[key].runtimeType}] e o valor informado é do tipo [${value.runtimeType}]'
                  },
                );
              }
            }
          } else {
            errors.add(
              {
                'message': 'Não é possivel alterar a configuração [$key]',
              },
            );
          }
        } else {
          errors.add(
            {
              'message': 'O valor [$key] não existe na configuração.',
            },
          );
        }
      });

      // Notificando Erros
      if (errors.isNotEmpty) {
        return MyResponse().notFound(
          {
            'message': 'Foram encontrados alguns erros.',
            'erros': errors,
          },
        );
      }

      // Alterar configurações
      body.forEach((key, value) {
        if (serverConfig.containsKey(key)) {
          serverConfig[key] = value;
        }
      });

      // Salvar novas configurações
      await File(path.join(serverDir.path, 'server.json')).writeAsString(
        json.encode(serverConfig),
      );

      return MyResponse().ok({
        'changes': body.length,
        'request_body': body,
        'config': serverConfig,
      });
    });

    return route;
  }
}

Response? validator(String serverId) {
  if (!Uuid.isValidUUID(fromString: serverId)) {
    return MyResponse().notFound(
      {
        'message': 'ID de servidor inválido.',
      },
    );
  }

  var serverDir = Directory.fromUri(
    Uri.directory(path.join(config.servers_dir, serverId)),
  );

  if (!serverDir.existsSync()) {
    return MyResponse().notFound(
      {
        'message': 'Nenhum servidor encontrado com este ID.',
      },
    );
  }
}

List<String> _properties = [
  'server_name',
  'server_port',
  'server_version',
  'provider',
];
