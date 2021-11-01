import 'dart:async';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:craft_panel/common/constants.dart';
import 'package:craft_panel/common/addons/default_message.dart';
import 'package:craft_panel/common/addons/my_response.dart';
import 'package:craft_panel/common/files/user_file.dart';
import 'package:craft_panel/common/utilities.dart';
import 'package:craft_panel/models/user.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../common/addons/response_addon.dart';

class AuthService {
  static Handler get route {
    var route = Router();

    route.post('/session', (Request request) async {
      final body = await request.jsonBody();
      late User user;
      if (body['username'] != null && body['password'] != null) {
        if (constainsUser(body['username'])) {
          user = getUser(body['username']);

          if (user.password != encodePassword(body['password'])) {
            return MyResponse().notFound({
              'message': 'Usuário ou senha, incorretos.',
            });
          }
        } else {
          return MyResponse().notFound({
            'message': 'Usuário ou senha, incorretos.',
          });
        }

        return MyResponse().ok({
          'Authorization': _token(body['username']),
          'perms': user.permissions.map((e) => e.toString()).toList(),
        });
      }

      return MyResponse().notFound(
        DefaultMessage.invalidBody({
          'username': 'STRING',
          'password': 'STRING',
        }),
      );
    });

    return route;
  }

  static FutureOr<Response?> handle(Request request) async {
    if (request.url.toString().contains('auth/') ||
        request.url.toString().contains('versions/')) return null;

    if (request.headers.isEmpty || request.headers['Authorization'] == null) {
      return MyResponse().notFound({
        'message': 'Token expirado ou inexistente.',
      });
    }

    var token = request.headers['Authorization']!;
    var splitted = token.split(' ');
    if (splitted.length > 1) {
      token = splitted[1].trim();
    }

    try {
      var tk = JWT.verify(
        token,
        SecretKey(secret),
        checkExpiresIn: false,
      );
      if (tk.payload == null) {
        return MyResponse().notFound({'message': 'Token expirado.'});
      }
      if (tk.payload!['id'] == null) {
        return MyResponse().notFound({'message': 'Token expirado.'});
      }
      // var uid = tk.payload!['id'];
      // if (!Uuid.isValidUUID(fromString: uid)) {
      //   return MyResponse().notFound({'message': 'Token expirado.'});
      // }
      return null;
    } catch (e) {
      return MyResponse().notFound({
        'message': 'Token expirado.',
      });
    }
  }

  static String _token(id) {
    var time =
        DateTime.now().add(Duration(hours: 6)).millisecondsSinceEpoch ~/ 1000;
    final jwt = JWT({
      'id': id,
      'exp': time.toInt(),
    });

    return jwt.sign(SecretKey(secret));
  }
}
