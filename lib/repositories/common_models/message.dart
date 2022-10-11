/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 10:30:05
 * @LastEditTime : 2022-10-11 15:36:23
 * @Description  : 
 */

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:tcp_client/repositories/common_models/json_encodable.dart';
import 'package:tcp_client/repositories/file_repository/models/local_file.dart';

enum MessageType {
  plaintext('plaintext'),
  file('file'),
  image('image');

  factory MessageType.fromStringLiteral(String value) {
    return MessageType.values.firstWhere((element) => element._value == value);
  }
  const MessageType(String value): _value = value;
  final String _value;
  String get literal => _value;
}

class Message extends JSONEncodable {
  final int _userid;
  final int _targetid;
  final MessageType _contenttype;
  final String _content;
  final int _timestamp;
  late final String _contentmd5;
  final LocalFile? _payload;

  Message({
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
   _payload = payload {
    _contentmd5 = md5.convert(
      utf8.encode(content)
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = userid)
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = targetid)
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = _timestamp)
    ).toString();
  }

  Message.fromJSONObject({
    required Map<String, Object?> jsonObject,
    LocalFile? payload
  }):
    _userid = jsonObject['userid'] as int,
    _targetid = jsonObject['targetid'] as int,
    _contenttype = MessageType.fromStringLiteral(jsonObject['contenttype'] as String),
    _content = jsonObject['content'] as String,
    _timestamp = jsonObject['timestamp'] as int,
    _contentmd5 = jsonObject['md5encoded'] as String,
    _payload = payload;

  int get senderID => _userid;
  int get recieverID => _targetid;
  MessageType get type => _contenttype;
  String get contentDecoded => utf8.decode(base64.decode(_content));
  String get contentEncoded => _content;
  String get contentmd5 => _contentmd5;
  int get timeStamp => _timestamp;
  LocalFile? get payload => _payload;

  @override
  Map<String, Object?> get jsonObject => {
    'userid': _userid,
    'targetid': _targetid,
    'contenttype': _contenttype.literal,
    'content': _content,
    'timestamp': _timestamp,
    'md5Encoded': _contentmd5,
    'filemd5': payload?.filemd5
  };
}
