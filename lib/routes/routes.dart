import 'package:craft_panel/routes/action/action_service.dart';
import 'package:craft_panel/routes/auth/auth_service.dart';
import 'package:craft_panel/routes/server/server_service.dart';
import 'package:craft_panel/routes/versions/version_service.dart';
import 'package:shelf_router/shelf_router.dart';

class Routes {
  Router get router {
    var router = Router();

    router.mount('/auth/', AuthService.route);
    router.mount('/versions/', VersionService.route);
    router.mount('/server/', ServerService.route);
    router.mount('/action/', ActionService.route);

    return router;
  }
}
