/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 15:06:42
 * @LastEditTime : 2022-10-11 15:39:38
 * @Description  : 
 */
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:tcp_client/repositories/common_models/json_encodable.dart';

class UserIdentity extends JSONEncodable {
  final String _username;
  final String _oldPasswd;
  final String? _newPasswd;

  UserIdentity({
    required String username,
    required String password,
    String? newPassword
  }):
    _username = base64.encode(utf8.encode(username)),
    _oldPasswd = md5.convert(password.codeUnits).toString(),
    _newPasswd = newPassword != null ? 
      md5.convert(newPassword.codeUnits).toString() : null;
  
  UserIdentity.fromJSONObject({
    required Map<String, Object?> jsonObject
  }):
    _username = jsonObject['username'] as String,
    _oldPasswd = jsonObject['passwd'] as String,
    _newPasswd = jsonObject['newPasswd'] as String?;
  
  String get userName => utf8.decode(base64.decode(_username));
  String get password => _oldPasswd;
  String? get newPassword => _newPasswd;

  @override
  Map<String, Object?> get jsonObject => {
    'username': _username,
    'passwd': _oldPasswd,
    'newPasswd': _newPasswd
  };
}