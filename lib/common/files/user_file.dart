import 'package:craft_panel/common/files/file_generator.dart';
import 'package:craft_panel/models/permission.dart';
import 'package:craft_panel/models/user.dart';

List<Permission>? permissions;
List<User>? users;

void loadUsers() {
  var fg = FileConfig(
    fileName: 'users.json',
    content: {
      'users': [
        {
          'username': 'admin',
          'password': '21232f297a57a5a743894a0e4a801fc3',
          'permissions': Permission.values.map((e) => e.toString()).toList(),
        },
      ]
    },
  );

  users = (fg.content['users'] as List).map((e) => User.fromJson(e)).toList();
}

User getUser(id) => users!.firstWhere((element) => element.username == id);

bool constainsUser(id) =>
    users!.where((element) => element.username == id).isNotEmpty;
