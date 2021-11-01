import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:craft_panel/common/constants.dart';

String encodePassword(String password) {
  return Encrypter(AES(key)).encrypt(password, iv: IV.fromLength(16)).base64;
  // print(encripter.decrypt64(hash.base64, iv: iv));
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
