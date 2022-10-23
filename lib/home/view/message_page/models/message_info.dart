/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:48:54
 * @LastEditTime : 2022-10-23 16:30:08
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/common_models/message.dart';

class MessageInfo extends Equatable {
  final Message? message;
  final int targetUser;

  const MessageInfo({
    this.message,
    required this.targetUser,
  });

  MessageInfo copyWith({
    Message? message,
    int? targetUser,
    int? unreadCount
  }) {
    return MessageInfo(
      message: message ?? this.message,
      targetUser: targetUser ?? this.targetUser,
    );
  }

  @override
  List<Object> get props => [message?.contentmd5 ?? '', targetUser];
}
