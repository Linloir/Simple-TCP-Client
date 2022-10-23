/*
 * @Author       : Linloir
 * @Date         : 2022-10-23 16:30:45
 * @LastEditTime : 2022-10-23 17:46:28
 * @Description  : 
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_tile/msg_tile_state.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class MessageTileCubit extends Cubit<MessageTileState> {
  MessageTileCubit({
    required this.tcpRepository,
    required this.localServiceRepository,
    required this.targetID
  }): super(const MessageTileState(unreadCount: 0)) {
    Future<int>(() async {
      return await localServiceRepository.getUnreadCount(
        userid: (await SharedPreferences.getInstance()).getInt('userid')!, 
        targetid: targetID
      );
    }).then((value) => emit(state + value));
    subscription = tcpRepository.responseStreamBroadcast.listen(_onResponse);
  }

  final TCPRepository tcpRepository;
  final LocalServiceRepository localServiceRepository;
  final int targetID;
  late final StreamSubscription subscription;

  Future<void> _onResponse(TCPResponse response) async {
    var pref = await SharedPreferences.getInstance();
    var userID = pref.getInt('userid');
    if(userID == null) {
      return;
    }
    var readHistoryTimestamp = await localServiceRepository.fetchReadHistory(
      userid: userID, 
      targetid: targetID
    );
    if(response.type == TCPResponseType.fetchMessage) {
      //Count unread incoming message count
      response as FetchMessageResponse;
      var addCnt = 0;
      for(var message in response.messages) {
        if(message.senderID == targetID && message.recieverID == userID) {
          if(readHistoryTimestamp < message.timeStamp) {
            addCnt += 1;
          }
        }
      }
      if(!isClosed) {
        emit(state + addCnt);
      }
    }
    else if(response.type == TCPResponseType.forwardMessage) {
      //Count unread incoming message count
      response as ForwardMessageResponse;
      if(response.message.senderID == targetID && response.message.recieverID == userID) {
        if(readHistoryTimestamp < response.message.timeStamp) {
          if(!isClosed) {
            emit(state + 1);
          }
        }
        else {
          if(!isClosed) {
            emit(const MessageTileState(unreadCount: 0));
          }
        }
      }
    }
  }

  void clearUnread() {
    emit(const MessageTileState(unreadCount: 0));
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
