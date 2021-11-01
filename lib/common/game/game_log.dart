import 'package:craft_panel/common/game/mine_server.dart';

class GameLog {
  Map<String, MineServer> servers = {};

  bool running(String serverId) => servers.containsKey(serverId);
}
