class Config {
  final String JWTSecret, servers_dir;

  Config({
    required this.JWTSecret,
    required this.servers_dir,
  });

  Config.fromJson(Map<String, dynamic> json)
      : JWTSecret = json['jwt_secret'],
        servers_dir = json['servers_dir'];
}
