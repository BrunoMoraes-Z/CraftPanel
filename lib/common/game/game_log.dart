import 'package:craft_panel/common/game/mine_server.dart';

class GameLog {
  Map<String, MineServer> servers = {};
  List<String> starting = [];

  bool running(String serverId) => servers.containsKey(serverId);
}
