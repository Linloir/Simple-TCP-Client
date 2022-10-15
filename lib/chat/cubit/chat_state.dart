/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:52
 * @LastEditTime : 2022-10-14 23:04:07
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/chat/model/chat_history.dart';

enum ChatStatus { fetching, partial, full }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatHistory> chatHistory;

  const ChatState({required this.chatHistory, required this.status});

  static ChatState empty() => const ChatState(chatHistory: [], status: ChatStatus.fetching);

  ChatState copyWith({
    ChatStatus? status,
    List<ChatHistory>? chatHistory
  }) {
    return ChatState(
      status: status ?? this.status,
      chatHistory: chatHistory ?? this.chatHistory
    );
  }

  @override
  List<Object> get props => [...chatHistory, status];
}
