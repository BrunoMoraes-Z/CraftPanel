import 'dart:io';

import 'package:craft_panel/common/addons/fix_cors.dart';
import 'package:craft_panel/common/constants.dart';
import 'package:craft_panel/common/files/config_file.dart';
import 'package:craft_panel/common/files/user_file.dart';
import 'package:craft_panel/common/game/game_log.dart';
import 'package:craft_panel/common/utilities.dart';
import 'package:craft_panel/routes/auth/auth_service.dart';
import 'package:craft_panel/routes/routes.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  if (!await loadConfig()) return;

  gameLog = GameLog();

  loadUsers();

  var app = Router();

  var handler = shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(fixCORS)
      .addMiddleware(shelf.createMiddleware(requestHandler: AuthService.handle))
      .addHandler(app);

  app.mount('/', Routes().router);

  SecurityContext? context;
  if (isHttps()) {
    context = SecurityContext();
    context.useCertificateChain(
      '${sysDir.path}/server_chain.pem',
    );
    context.usePrivateKey(
      '${sysDir.path}/server_key.pem',
      password: 'onix',
    );
  }

  var server = await io.serve(
    handler,
    await localMachineIP(),
    3000,
    shared: true,
    securityContext: context,
  );

  print('Server running on ${server.address.host}:${server.port}\n');
}
