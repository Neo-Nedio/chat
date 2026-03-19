import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../api/user_api.dart';

final _useApi = UserApi();

//使用 RSA非对称加密 对密码进行加密
Future<String> passwordEncrypt(String password) async {
  //获取加密公钥
  final publicKeyResult = await _useApi.publicKey();
  //加密
  if (publicKeyResult['code'] == 0) {
    String key = publicKeyResult['data'];
    final parsedKey = encrypt.RSAKeyParser().parse(key) as RSAPublicKey;
    final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: parsedKey));
    final encryptedPassword = encrypter.encrypt(password).base64;
    return encryptedPassword;
  }
  return "-1";
}
