/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:52
 * @LastEditTime : 2022-10-14 13:42:46
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/common_models/message.dart';

enum ChatStatus { fetching, partial, full }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<Message> chatHistory;

  const ChatState({required this.chatHistory, required this.status});

  static ChatState empty() => const ChatState(chatHistory: [], status: ChatStatus.fetching);

  @override
  List<Object> get props => [chatHistory];
}
