/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:56
 * @LastEditTime : 2022-10-14 13:47:33
 * @Description  : 
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:tcp_client/chat/cubit/chat_state.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.localServiceRepository,
    required this.tcpRepository
  }): super(ChatState.empty()) {
    subscription = tcpRepository.responseStreamBroadcast.listen(_onResponse);
  }

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  late final StreamSubscription subscription;

  void addMessage(Message message) {
    //Store locally
    //Send to server
    //Emit new state
  }

  void _onResponse(TCPResponse response) {

  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
