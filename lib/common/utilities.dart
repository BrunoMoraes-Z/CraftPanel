import 'dart:convert';
import 'dart:io';

import 'package:craft_panel/common/constants.dart';
import 'package:crypto/crypto.dart';

String encodePassword(String password) {
  return md5.convert(utf8.encode(password)).toString();
}

bool isHttps() {
  var chain = File.fromUri(
    Uri.file('${sysDir.path}/server_chain.pem'),
  ).existsSync();
  var key = File.fromUri(
    Uri.file('${sysDir.path}/server_key.pem'),
  ).existsSync();
  return chain && key;
}

Future<String> localMachineIP() async {
  var interfaces = await NetworkInterface.list();
  var ips = [];
  interfaces.forEach((element) {
    if (element.addresses.isNotEmpty) {
      element.addresses.forEach((element) {
        if (element.type == InternetAddressType.IPv4) {
          if (element.address.startsWith('192.168')) {
            ips.add(element.address);
          }
        }
      });
    }
  });

  return ips.isEmpty ? 'localhost' : ips.first;
}
