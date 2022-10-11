/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 14:30:10
 * @LastEditTime : 2022-10-11 15:39:13
 * @Description  : 
 */

import 'package:tcp_client/repositories/common_models/json_encodable.dart';

class UserInfo extends JSONEncodable {
  final int _userid;
  final String _username;
  final String? _avatar;

  const UserInfo({
    required int userid,
    required String username,
    String? avatar
  }):
    _userid = userid,
    _username = username,
    _avatar = avatar;
  
  UserInfo.fromJSONObject({
    required Map<String, Object?> jsonObject
  }):
    _userid = jsonObject['userid'] as int,
    _username = jsonObject['username'] as String,
    _avatar = jsonObject['avatar'] as String?;
  
  int get userID => _userid;
  String get userName => _username;
  String? get avatarEncoded => _avatar;

  @override
  Map<String, Object?> get jsonObject => {
    'userid': _userid,
    'username': _username,
    'avatar': _avatar
  };
}
