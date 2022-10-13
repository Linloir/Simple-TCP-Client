/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:48:54
 * @LastEditTime : 2022-10-13 22:24:01
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class MessageInfo extends Equatable {
  final Message? message;
  final int targetUser;

  const MessageInfo({
    this.message,
    required this.targetUser
  });

  @override
  List<Object?> get props => [message?.contentmd5, targetUser];
}
