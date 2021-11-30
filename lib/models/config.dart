import 'package:craft_panel/common/constants.dart';

class Config {
  final String JWTSecret, servers_dir;
  late String _dns;

  Config({
    required this.JWTSecret,
    required this.servers_dir,
  });

  Config.fromJson(Map<String, dynamic> json)
      : JWTSecret = json['jwt_secret'],
        _dns = json['dns'],
        servers_dir = json['servers_dir'];

  String get dns => _dns.isEmpty ? serverIP : _dns;
}
