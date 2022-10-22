/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 09:44:03
 * @LastEditTime : 2022-10-22 21:01:35
 * @Description  : Abstract TCP request class
 */

export 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/common_models/useridentity.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';

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
  ackFetch      ('ACKFETCH'),       //Acknowledge message fetch
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
  final int? _token;

  const TCPRequest({required TCPRequestType type, required int? token}): _type = type, _token = token;

  TCPRequestType get type => _type;
  int? get token => _token;

  Map<String, Object?> get body;

  String toJSON() {
    return jsonEncode({
      'request': type.value,
      'body': body,
      'tokenid': token
    });
  }
  
  Stream<List<int>> get stream async* {
    var jsonString = toJSON();
    var requestLength = jsonString.length;
    yield Uint8List(4)..buffer.asInt32List()[0] = requestLength;
    yield Uint8List(8)..buffer.asInt64List()[0] = 0;
    yield Uint8List.fromList(jsonString.codeUnits);
  }
}

class CheckStateRequest extends TCPRequest {
  const CheckStateRequest({required int? token}): super(type: TCPRequestType.checkState, token: token);

  @override
  Map<String, Object?> get body => {};
}

class RegisterRequest extends TCPRequest {
  final UserIdentity _identity;
  
  RegisterRequest({
    required UserIdentity identity,
    required int? token
  }): _identity = identity, super(type: TCPRequestType.register, token: token);

  @override
  Map<String, Object?> get body => _identity.jsonObject;
}

class LoginRequest extends TCPRequest {
  final UserIdentity _identity;
  
  LoginRequest({
    required UserIdentity identity,
    required int? token
  }): _identity = identity, super(type: TCPRequestType.login, token: token);

  @override
  Map<String, Object?> get body => _identity.jsonObject;
}

class LogoutRequest extends TCPRequest {
  const LogoutRequest({required int? token}): super(type: TCPRequestType.logout, token: token);

  @override
  Map<String, Object?> get body => {};
}

class GetProfileRequest extends TCPRequest {
  const GetProfileRequest({
    required int userid, 
    required int? token
  }): _userid = userid, super(type: TCPRequestType.profile, token: token);

  final int _userid;

  int get userid => _userid;

  @override
  Map<String, Object?> get body => {
    'userid': _userid
  };
}

class ModifyPasswordRequest extends TCPRequest {
  final UserIdentity _identity;
  
  ModifyPasswordRequest({
    required UserIdentity identity,
    required int? token
  }): _identity = identity, super(type: TCPRequestType.modifyPassword, token: token);

  @override
  Map<String, Object?> get body => _identity.jsonObject;
}

class ModifyProfileRequest extends TCPRequest {
  final UserInfo _userinfo;

  const ModifyProfileRequest ({
    required UserInfo userInfo,
    required int? token
  }): _userinfo = userInfo, super(type: TCPRequestType.modifyProfile, token: token);

  @override
  Map<String, Object?> get body => _userinfo.jsonObject;
}

class SendMessageRequest extends TCPRequest {
  final Message _message;

  SendMessageRequest({
    required Message message,
    required int? token
  }):
   _message = message,
   super(type: TCPRequestType.sendMessage, token: token);

  @override
  Map<String, Object?> get body => _message.jsonObject;

  Message get message => _message;

  @override
  Stream<List<int>> get stream async* {
    var jsonString = toJSON();
    var requestLength = jsonString.length;
    yield Uint8List(4)..buffer.asInt32List()[0] = requestLength;
    yield Uint8List(8)..buffer.asInt64List()[0] =  (await _message.payload?.file.length()) ?? 0;
    yield Uint8List.fromList(jsonString.codeUnits);
    if(_message.payload != null) {
      var fileStream = _message.payload!.file.openRead();
      await for(var bytes in fileStream) {
        yield bytes;
      }
    }
  }
}

class FetchMessageRequest extends TCPRequest {
  const FetchMessageRequest({required int? token}): super(type: TCPRequestType.fetchMessage, token: token);

  @override
  Map<String, Object?> get body => {};
}

class FindFileRequest extends TCPRequest {
  final LocalFile _file;

  const FindFileRequest({required LocalFile file, required int? token}): _file = file, super(type: TCPRequestType.findFile, token: token);

  @override
  Map<String, Object?> get body => {
    'filemd5': _file.filemd5
  };

  LocalFile get file => _file;
}

class FetchFileRequest extends TCPRequest {
  final String _msgmd5;

  const FetchFileRequest({required String msgmd5, required int? token}): _msgmd5 = msgmd5, super(type: TCPRequestType.fetchFile, token: token);

  @override
  Map<String, Object?> get body => {
    'msgmd5': _msgmd5,
  };

  String get msgmd5 => _msgmd5;
}

class SearchUserRequest extends TCPRequest {
  final String _username;

  SearchUserRequest({required String username, required int? token}): 
    _username = base64.encode(utf8.encode(username)), super(type: TCPRequestType.searchUser, token: token);

  @override
  Map<String, Object?> get body => {
    'username': _username,
  };

  String get username => utf8.decode(base64.decode(_username));
}

class AddContactRequest extends TCPRequest {
  final int _userid;

  const AddContactRequest({required int userid, required int? token}): _userid = userid, super(type: TCPRequestType.addContact, token: token);

  @override
  Map<String, Object?> get body => {
    'userid': _userid,
  };

  int get userid => _userid;
}

class FetchContactRequest extends TCPRequest {
  const FetchContactRequest({required int? token}): super(type: TCPRequestType.fetchContact, token: token);

  @override
  Map<String, Object?> get body => {};
}

class AckFetchRequest extends TCPRequest {
  final int _timeStamp;

  const AckFetchRequest({required int timeStamp, required int? token}): _timeStamp = timeStamp, super(type: TCPRequestType.ackFetch, token: token);

  @override
  Map<String, Object?> get body => {
    'timestamp': _timeStamp
  };
}