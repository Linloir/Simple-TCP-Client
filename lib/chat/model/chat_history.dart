/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 14:55:20
 * @LastEditTime : 2022-10-18 15:19:46
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/common_models/message.dart';

enum ChatHistoryType { outcome, income }
enum ChatHistoryStatus { none, processing, sending, downloading, done, failed }

class ChatHistory extends Equatable {
  final Message message;
  final ChatHistoryType type;
  final ChatHistoryStatus status;

  const ChatHistory({
    required this.message,
    required this.type,
    required this.status
  });

  ChatHistory copyWith({
    Message? message,
    ChatHistoryType? type,
    ChatHistoryStatus? status
  }) {
    return ChatHistory(
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status
    );
  }

  @override
  List<Object> get props => [message.contentmd5, type, status];
}
