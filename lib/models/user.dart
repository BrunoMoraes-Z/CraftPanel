import 'package:craft_panel/models/permission.dart';

class User {
  final String username, password;
  final List<Permission> permissions;

  User({
    required this.username,
    required this.password,
    required this.permissions,
  });

  User.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        password = json['password'],
        permissions = _convert(json['permissions']);

  Map<String, dynamic> toJson() {
    var body = {
      'username': username,
      'password': password,
      'permissions': permissions.map((e) => e.toString()).toList(),
    };
    return body;
  }

  bool containsPermission(dynamic permission) {
    var perm = _toPermission(permission);
    if (perm != null) {
      return permissions.contains(perm);
    }
    return false;
  }

  void removePermission(dynamic permission) {
    var perm = _toPermission(permission);
    if (containsPermission(perm) && perm != null) {
      permissions.remove(perm);
    }
  }

  void addPermission(dynamic permission) {
    var perm = _toPermission(permission);
    if (!containsPermission(perm) && perm != null) {
      permissions.add(perm);
    }
  }

  Permission? _toPermission(dynamic permission) {
    if (permission is Permission) {
      return permission;
    } else if (permission is String) {
      var con = Permission.values
          .where((element) => element.toString() == permission);
      return con.isNotEmpty ? con.first : null;
    }
  }

  static List<Permission> _convert(dynamic input) {
    if (input is List) {
      List<Permission> list = [];
      var perms = {};
      Permission.values.forEach((element) {
        perms[element.toString()] = element;
      });
      perms.forEach((key, value) {
        if (input.contains(key)) {
          list.add(value);
        }
      });
      return list;
    }
    return List.empty();
  }
}
