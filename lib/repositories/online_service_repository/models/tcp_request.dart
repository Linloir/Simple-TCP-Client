/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 09:44:03
 * @LastEditTime : 2022-10-11 11:37:13
 * @Description  : Abstract TCP request class
 */

export 'package:tcp_client/repositories/online_service_repository/models/tcp_request.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:tcp_client/repositories/common_models/message_type.dart';
import 'package:tcp_client/repositories/file_repository/models/local_file.dart';

enum TCPRequestType {
  checkState    ('STATE'),          //Check login state for device token
  register      ('REGISTER'),       //Register new user
  login         ('LOGIN'),          //Login via username and password
  logout        ('LOGOUT'),         //Logout for current device token
  profile       ('PROFILE'),        //Fetch current logged in user profile
  modifyPassword('MODIFYPASSWD'),   //Modify user password
  modifyProfile ('MODIFYPROFILE'),  //Modify user profile
  sendMessage   ('SENDMSG'),        //Send message
  fetchMessage  ('FETCHMSG'),       //Fetch message
  findFile      ('FINDFILE'),       //Find file by md5 before transmitting the file
  fetchFile     ('FETCHFILE'),      //Fetch file and file md5 by message md5
  searchUser    ('SEARCHUSR'),      //Search username and userid by username
  addContact    ('ADDCONTACT'),     //Add one-way relation to a user
  fetchContact  ('FETCHCONTACT'),   //Fetch all contacts, including requesting and pending
  unknown       ('UNKNOWN');        //Wrong command

  const TCPRequestType(String value): _value = value;
  final String _value;
  String get value => _value;

  //Construct the enum type by value
  factory TCPRequestType.fromValue(String value) {
    return TCPRequestType.values.firstWhere((element) => element._value == value, orElse: () => TCPRequestType.unknown);
  }
}

abstract class TCPRequest {
  final TCPRequestType _type;
  final int _token;

  const TCPRequest({required TCPRequestType type, required int token}): _type = type, _token = token;

  TCPRequestType get type => _type;
  int get token => _token;

  Map<String, Object?> get body;

  String toJSON() {
    return jsonEncode({
      'request': type.value,
      'body': body,
      'token': token
    });
  }
}

class CheckStateRequest extends TCPRequest {
  const CheckStateRequest({required int token}): super(type: TCPRequestType.checkState, token: token);

  @override
  Map<String, Object?> get body => {};
}

class RegisterRequest extends TCPRequest {
  final String _username;
  final String _password;
  
  RegisterRequest({
    required username, 
    required password, 
    required token
  }): 
    _username = username,
    _password = md5.convert(password.codeUnits).toString(),
    super(type: TCPRequestType.register, token: token);

  @override
  Map<String, Object?> get body => {
    'username': _username,
    'passwd': _password
  };
}

class LoginRequest extends TCPRequest {
  final String _username;
  final String _password;

  LoginRequest({
    required String username,
    required String password,
    required int token
  }):
    _username = username,
    _password = md5.convert(password.codeUnits).toString(),
    super(type: TCPRequestType.login, token: token);
  
  @override
  Map<String, Object?> get body => {
    'username': _username,
    'passwd': _password
  };
}

class LogoutRequest extends TCPRequest {
  const LogoutRequest({required int token}): super(type: TCPRequestType.logout, token: token);

  @override
  Map<String, Object?> get body => {};
}

class GetProfileRequest extends TCPRequest {
  const GetProfileRequest({required int token}): super(type: TCPRequestType.profile, token: token);

  @override
  Map<String, Object?> get body => {};
}

class ModifyPasswordRequest extends TCPRequest {
  final String _username;
  final String _oldPassword;
  final String _newPassword;

  ModifyPasswordRequest({
    required String username,
    required String oldPassword,
    required String newPassowrd,
    required int token
  }):
    _username = username,
    _oldPassword = md5.convert(oldPassword.codeUnits).toString(),
    _newPassword = md5.convert(newPassowrd.codeUnits).toString(),
    super(type: TCPRequestType.modifyPassword, token: token);

  @override
  Map<String, Object?> get body => {
    'username': _username,
    'passwd': _oldPassword,
    'newPasswd': _newPassword
  };
}

class ModifyProfileRequest extends TCPRequest {
  final int _userid;
  final String _username;
  final String _avatar;

  const ModifyProfileRequest ({
    required int userid,        //Note: This can be fetched from local_service_repository
    required String username,
    required String avatar,
    required int token
  }):
    _userid = userid,
    _username = username,
    _avatar = avatar,
    super(type: TCPRequestType.modifyProfile, token: token);

  @override
  Map<String, Object?> get body => {
    'userid': _userid,
    'username': _username,
    'avatar': _avatar
  };
}

class SendMessageRequest extends TCPRequest {
  final int _userid;
  final int _targetid;
  final MessageType _contenttype;
  final String _content;
  final int _timestamp;
  late final String _contentmd5;
  final LocalFile? _payload;

  SendMessageRequest({
    required int userid,
    required int targetid,
    required MessageType contenttype,
    required String content,
    LocalFile? payload,
    required int token
  }):
   _userid = userid,
   _targetid = targetid,
   _contenttype = contenttype,
   _content = base64.encode(utf8.encode(content)),
   _timestamp = DateTime.now().millisecondsSinceEpoch,
   _payload = payload,
   super(type: TCPRequestType.sendMessage, token: token) {
    _contentmd5 = md5.convert(
      utf8.encode(content)
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = userid)
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = targetid)
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = _timestamp)
    ).toString();
   }

  @override
  Map<String, Object?> get body => {
    'userid': _userid,
    'targetid': _targetid,
    'contenttype': _contenttype.literal,
    'content': _content,
    'timestamp': _timestamp,
    'md5Encoded': _contentmd5,
    'filemd5': _payload?.filemd5
  };

  LocalFile? get payload => _payload;
}

class FetchMessageRequest extends TCPRequest {
  const FetchMessageRequest({required int token}): super(type: TCPRequestType.fetchMessage, token: token);

  @override
  Map<String, Object?> get body => {};
}

class FindFileRequest extends TCPRequest {
  final LocalFile _file;

  const FindFileRequest({required LocalFile file, required int token}): _file = file, super(type: TCPRequestType.findFile, token: token);

  @override
  Map<String, Object?> get body => {
    'filemd5': _file.filemd5
  };

  LocalFile get file => _file;
}

class FetchFileRequest extends TCPRequest {
  final String _msgmd5;

  const FetchFileRequest({required String msgmd5, required int token}): _msgmd5 = msgmd5, super(type: TCPRequestType.fetchFile, token: token);

  @override
  Map<String, Object?> get body => {
    'msgmd5': _msgmd5,
  };

  String get msgmd5 => _msgmd5;
}

class SearchUserRequest extends TCPRequest {
  final String _username;

  const SearchUserRequest({required String username, required int token}): _username = username, super(type: TCPRequestType.searchUser, token: token);

  @override
  Map<String, Object?> get body => {
    'username': _username,
  };

  String get username => _username;
}

class AddContactRequest extends TCPRequest {
  final int _userid;

  const AddContactRequest({required int userid, required int token}): _userid = userid, super(type: TCPRequestType.addContact, token: token);

  @override
  Map<String, Object?> get body => {
    'userid': _userid,
  };

  int get userid => _userid;
}

class FetchContactRequest extends TCPRequest {
  const FetchContactRequest({required int token}): super(type: TCPRequestType.fetchContact, token: token);

  @override
  Map<String, Object?> get body => {};
}