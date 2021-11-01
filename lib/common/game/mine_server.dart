import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:craft_panel/common/constants.dart';
import 'package:craft_panel/common/files/config_file.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class MineServer {
  final String serverName, version, provider;
  final int serverPort, minRam, maxRam;
  late String id;
  late Directory serverDir;
  final List<String> logs = [];
  late Process process;

  MineServer({
    required this.serverName,
    required this.serverPort,
    required this.provider,
    required this.version,
    required this.minRam,
    required this.maxRam,
    this.id = '',
  }) {
    if (id.isEmpty) {
      id = Uuid().v4();
    }
    serverDir = Directory.fromUri(Uri.directory('${config.servers_dir}/$id'));
  }

  dynamic serverInfo() {
    return {
      'server_id': id,
      'server_name': serverName,
      'server_port': serverPort,
      'min_ram': minRam,
      'max_ram': maxRam,
      'provider': provider,
      'path': '${config.servers_dir}/$id'
    };
  }

  FutureOr<dynamic>? start() async {
    var completer = Completer<dynamic>();

    if (gameLog!.running(id)) {
      return {'message': 'Server already running!'};
    }

    if (logs.isNotEmpty) {
      logs.clear();
    }

    gameLog!.servers[id] = this;

    var args = [
      '-jar',
      '-Xms${minRam}M',
      '-Xmx${maxRam}M',
      'server.jar',
    ];

    if (provider == 'paper') {
      args.add('-nogui');
    }

    final dir = serverDir.path
        .substring(0, serverDir.path.length - 1)
        .replaceAll('\\', '/');

    process = await Process.start(
      'java',
      args,
      workingDirectory: dir,
    );

    process.stdout.transform(utf8.decoder).listen((event) {
      event.split('\r\n').forEach((element) {
        if (element.trim().isNotEmpty) {
          logs.add(element);
        }
      });

      if ((!completer.isCompleted) &&
          RegExp(r'''Done \([0-9]{1,}\.[0-9]{3,}s\)! For help, type "help"''')
              .hasMatch(event)) {
        completer.complete(null);
      }
    });

    return await completer.future;
  }

  Future<dynamic>? stop() async {
    if (!gameLog!.running(id)) {
      return {'message': 'Server is not running!'};
    }
    await run('stop');
    await process.exitCode;
    gameLog!.servers.remove(id);
  }

  Future<dynamic>? run(String command) async {
    if (!gameLog!.running(id)) {
      return {'message': 'Server is not running!'};
    }
    process.stdin.writeln(command);
    return null;
  }

  Future<void> mountServer() async {
    if (!serverDir.existsSync()) {
      serverDir.createSync();

      File(path.join(serverDir.path, 'eula.txt'))
          .writeAsStringSync('eula=true');

      File(path.join(serverDir.path, 'server.properties')).writeAsStringSync(
        'online-mode=false\nmax-slots=20\nserver-port=$serverPort\nspawn-protection=0\nmotd=\u00A77Servidor criado Utilizando\\n\u00A7bDart server Panel',
      );

      var info = serverInfo();
      info['jar'] = 'server.jar';
      File(path.join(serverDir.path, 'server.json')).writeAsStringSync(
        json.encode(info),
      );

      var url;
      if (provider.toLowerCase() == 'paper') {
        var uri = Uri.parse('https://serverjars.com/api/fetchAll/paper');

        var response = await http.get(uri);
        Map<String, dynamic> version_manifest = json.decode(response.body);

        for (Map<String, dynamic> value in version_manifest['response']) {
          if (value['version'] != version) continue;
          url = 'https://serverjars.com/api/fetchJar/paper/$version';
          break;
        }
      } else {
        if (version.contains('1.12')) {
          url = 'https://mohistmc.com/api/1.12.2/latest';
        } else {
          url = 'https://mohistmc.com/api/1.16.5/latest';
        }

        var response = await http.get(Uri.parse(url));
        Map<String, dynamic> version_manifest = json.decode(response.body);
        url = version_manifest['url'];
      }
      await _downloadFile(url, path.join(serverDir.path, 'server.jar'));
    }
  }

  Future<String> _downloadFile(String uri, String file) {
    var c = Completer<String>();
    HttpClient()
        .getUrl(Uri.parse(uri))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) {
      response.pipe(File(file).openWrite()).then((a) {
        c.complete(file);
      });
    });
    return c.future;
  }
}
