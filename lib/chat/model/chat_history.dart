/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 14:55:20
 * @LastEditTime : 2022-10-20 11:01:03
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tcp_client/repositories/common_models/message.dart';

enum ChatHistoryType { outcome, income }
enum ChatHistoryStatus { none, processing, sending, downloading, done, failed }

class ChatHistory extends Equatable {
  final Message message;
  final ChatHistoryType type;
  final ChatHistoryStatus status;
  final Image? preCachedImage;

  const ChatHistory({
    required this.message,
    required this.type,
    required this.status,
    this.preCachedImage,
  });

  ChatHistory copyWith({
    Message? message,
    ChatHistoryType? type,
    ChatHistoryStatus? status,
    Image? preCachedImage
  }) {
    return ChatHistory(
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status,
      preCachedImage: preCachedImage ?? this.preCachedImage
    );
  }

  @override
  List<Object> get props => [message.contentmd5, type, status];
}
