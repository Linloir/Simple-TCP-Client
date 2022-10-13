/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:48:54
 * @LastEditTime : 2022-10-12 23:50:17
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class MessageInfo extends Equatable {
  final Message? message;
  final UserInfo userInfo;

  const MessageInfo({
    this.message,
    required this.userInfo
  });

  @override
  List<Object?> get props => [message?.contentmd5, userInfo];
}
