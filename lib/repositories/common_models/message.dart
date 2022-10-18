/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 10:30:05
 * @LastEditTime : 2022-10-18 16:53:04
 * @Description  : 
 */

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:tcp_client/repositories/common_models/json_encodable.dart';
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';

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
  late final String? _filemd5;
  final LocalFile? _payload;

  Message._internal({
    required int userid,
    required int targetid,
    required MessageType contenttype,
    required String content,
    required int timestamp,
    required String contentmd5,
    required String? filemd5,
    required LocalFile? payload
  }): 
    _userid = userid,
    _targetid = targetid,
    _contenttype = contenttype,
    _content = content,
    _timestamp = timestamp,
    _contentmd5 = contentmd5,
    _filemd5 = filemd5,
    _payload = payload;

  Message({
    required int userid,
    required int targetid,
    required MessageType contenttype,
    required String content,
    LocalFile? payload
  }):
   _userid = userid,
   _targetid = targetid,
   _contenttype = contenttype,
   _content = base64.encode(utf8.encode(content)),
   _timestamp = DateTime.now().millisecondsSinceEpoch,
   _payload = payload {
    _contentmd5 = md5.convert(
      utf8.encode(content).toList()
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = userid)
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = targetid)
      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = _timestamp)
    ).toString();
    _filemd5 = _payload?.filemd5;
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
    _filemd5 = jsonObject['filemd5'] as String?,
    _payload = payload;
  
  Message copyWith({
    int? userid,
    int? targetid,
    MessageType? contenttype,
    String? content,
    int? timestamp,
    LocalFile? payload
  }) {
    return Message._internal(
      userid: userid ?? _userid,
      targetid: targetid ?? _targetid,
      contenttype: contenttype ?? _contenttype,
      content: content == null ? _content : base64.encode(utf8.encode(content)),
      timestamp: timestamp ?? _timestamp,
      contentmd5: content != null || userid != null || targetid != null ?
                    md5.convert(
                      utf8.encode(content ?? contentDecoded).toList()
                      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = userid ?? _userid)
                      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = targetid ?? _targetid)
                      ..addAll(Uint8List(4)..buffer.asInt32List()[0] = timestamp ?? _timestamp)
                    ).toString() : _contentmd5,
      filemd5: payload?.filemd5 ?? _filemd5,
      payload: payload ?? _payload
    );
  }

  int get senderID => _userid;
  int get recieverID => _targetid;
  MessageType get type => _contenttype;
  String get contentDecoded => utf8.decode(base64.decode(_content));
  String get contentEncoded => _content;
  String get contentmd5 => _contentmd5;
  int get timeStamp => _timestamp;
  String? get filemd5 => _filemd5;
  LocalFile? get payload => _payload;

  @override
  Map<String, Object?> get jsonObject => {
    'userid': _userid,
    'targetid': _targetid,
    'contenttype': _contenttype.literal,
    'content': _content,
    'timestamp': _timestamp,
    'md5encoded': _contentmd5,
    'filemd5': payload?.filemd5 ?? _filemd5
  };
}
