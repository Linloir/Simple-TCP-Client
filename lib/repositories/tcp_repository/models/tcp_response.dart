/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 11:02:19
 * @LastEditTime : 2022-10-18 14:11:36
 * @Description  : 
 */

import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';

enum TCPResponseType {
  token         ('TOKEN'),          //Only exists when server is sending message
  checkState    ('STATE'),          //Check login state for device token
  register      ('REGISTER'),       //Register new user
  login         ('LOGIN'),          //Login via username and password
  logout        ('LOGOUT'),         //Logout for current device token
  profile       ('PROFILE'),        //Fetch current logged in user profile
  modifyPassword('MODIFYPASSWD'),   //Modify user password
  modifyProfile ('MODIFYPROFILE'),  //Modify user profile
  sendMessage   ('SENDMSG'),        //Send message
  forwardMessage('FORWARDMSG'),     //Forward message
  fetchMessage  ('FETCHMSG'),       //Fetch message
  findFile      ('FINDFILE'),       //Find file by md5 before transmitting the file
  fetchFile     ('FETCHFILE'),      //Fetch file and file md5 by message md5
  searchUser    ('SEARCHUSR'),      //Search username and userid by username
  addContact    ('ADDCONTACT'),     //Add one-way relation to a user
  fetchContact  ('FETCHCONTACT'),   //Fetch all contacts, including requesting and pending
  unknown       ('UNKNOWN');        //Wrong command

  const TCPResponseType(String value): _value = value;
  final String _value;
  String get value => _value;

  //Construct the enum type by value
  factory TCPResponseType.fromValue(String value) {
    return TCPResponseType.values.firstWhere((element) => element._value == value, orElse: () => TCPResponseType.unknown);
  }
}

enum TCPResponseStatus {
  ok        ('OK'),
  err       ('ERR'),
  unknown   ('UNKNOWN');

  const TCPResponseStatus(String value): _value = value;
  final String _value;
  String get value => _value;

  //Construct the enum type by value
  factory TCPResponseStatus.fromValue(String value) {
    return TCPResponseStatus.values.firstWhere((element) => element._value == value, orElse: () => TCPResponseStatus.unknown);
  }
}

abstract class TCPResponse {
  late final TCPResponseType _type;
  late final TCPResponseStatus _status;
  late final String? _info;

  TCPResponse({
    required Map<String, Object?> jsonObject
  }) {
    _type = TCPResponseType.fromValue(jsonObject['response'] as String);
    _status = TCPResponseStatus.fromValue(jsonObject['status'] as String);
    _info = jsonObject['info'] as String?;
  }

  TCPResponseType get type => _type;
  TCPResponseStatus get status => _status;
  String? get info => _info;
}

class SetTokenReponse extends TCPResponse {
  final int _token;
  
  SetTokenReponse({
    required Map<String, Object?> jsonObject
  }): 
    _token = (jsonObject['body'] as Map<String, Object?>)['tokenid'] as int,
    super(jsonObject: jsonObject);
  
  int get token => _token;
}

class CheckStateResponse extends TCPResponse {
  late final UserInfo? _userInfo;

  CheckStateResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _userInfo = jsonObject['body'] == null ? null : UserInfo.fromJSONObject(jsonObject: jsonObject['body'] as Map<String, Object?>);
  }

  UserInfo? get userInfo => _userInfo;
}

class RegisterResponse extends TCPResponse {
  late final UserInfo? _userInfo;

  RegisterResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _userInfo = jsonObject['body'] == null ? null : UserInfo.fromJSONObject(jsonObject: jsonObject['body'] as Map<String, Object?>);
  }

  UserInfo? get userInfo => _userInfo;
}

class LoginResponse extends TCPResponse {
  late final UserInfo? _userInfo;

  LoginResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _userInfo = jsonObject['body'] == null ? null : UserInfo.fromJSONObject(jsonObject: jsonObject['body'] as Map<String, Object?>);
  }

  UserInfo? get userInfo => _userInfo;
}

class LogoutResponse extends TCPResponse {
  LogoutResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject);
}

class GetProfileResponse extends TCPResponse {
  late final UserInfo? _userInfo;

  GetProfileResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _userInfo = jsonObject['body'] == null ? null : UserInfo.fromJSONObject(jsonObject: jsonObject['body'] as Map<String, Object?>);
  }

  UserInfo? get userInfo => _userInfo;
}

class ModifyPasswordResponse extends TCPResponse {
  ModifyPasswordResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject);
}

class ModifyProfileResponse extends TCPResponse {
  late final UserInfo? _userInfo;

  ModifyProfileResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _userInfo = jsonObject['body'] == null ? null : UserInfo.fromJSONObject(jsonObject: jsonObject['body'] as Map<String, Object?>);
  }

  UserInfo? get userInfo => _userInfo;
}

class SendMessageResponse extends TCPResponse {
  late final String? _md5encoded;
  
  SendMessageResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _md5encoded = jsonObject['body'] == null ? null : (jsonObject['body'] as Map<String, Object?>)['md5encoded'] as String?;
  }

  String? get md5encoded => _md5encoded;
}

class ForwardMessageResponse extends TCPResponse {
  late final Message _message;

  ForwardMessageResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _message = Message.fromJSONObject(jsonObject: jsonObject['body'] as Map<String, Object?>);
  }

  Message get message => _message;
}

class FetchMessageResponse extends TCPResponse {
  late final List<Message> _messages;

  FetchMessageResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _messages = (((jsonObject['body'] as Map<String, Object?>?) ?? {'messages': []})['messages'] as List)
      .map((e) => Message.fromJSONObject(jsonObject: e)).toList();
  }

  List<Message> get messages => _messages;
}

class FindFileResponse extends TCPResponse {
  FindFileResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject);

  bool get foundIdentical => status == TCPResponseStatus.ok;
}

class FetchFileResponse extends TCPResponse {
  late final LocalFile _payload;

  FetchFileResponse({
    required Map<String, Object?> jsonObject,
    required LocalFile payload
  }): super(jsonObject: jsonObject) {
    _payload = LocalFile(
      file: payload.file, 
      filemd5: payload.filemd5
    );
  }

  LocalFile get payload => _payload;
}

class SearchUserResponse extends TCPResponse {
  late final UserInfo? _userInfo;

  SearchUserResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    _userInfo = jsonObject['body'] == null ? null : UserInfo.fromJSONObject(jsonObject: jsonObject['body'] as Map<String, Object?>);
  }

  UserInfo? get userInfo => _userInfo;
}

class AddContactResponse extends TCPResponse {
  AddContactResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject);
}

class FetchContactResponse extends TCPResponse {
  late final List<UserInfo> _added;
  late final List<UserInfo> _pending;
  late final List<UserInfo> _requesting;

  FetchContactResponse({
    required Map<String, Object?> jsonObject
  }): super(jsonObject: jsonObject) {
    var body = jsonObject['body'] as Map<String, Object?>? ?? {
      'contacts': [],
      'pending': [],
      'requesting': []
    };
    var rawAddedContacts = body['contacts'] as List;
    var rawPendingContacts = body['pending'] as List;
    var rawRequestingContacts = body['requesting'] as List;
    _added = rawAddedContacts.map((e) => UserInfo.fromJSONObject(jsonObject: e)).toList();
    _pending = rawPendingContacts.map((e) => UserInfo.fromJSONObject(jsonObject: e)).toList();
    _requesting = rawRequestingContacts.map((e) => UserInfo.fromJSONObject(jsonObject: e)).toList();
  }

  List<UserInfo> get addedContacts => _added;
  List<UserInfo> get pendingContacts => _pending;
  List<UserInfo> get requestingContacts => _requesting;
}