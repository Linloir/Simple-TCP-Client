/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:38:31
 * @LastEditTime : 2022-10-21 23:14:02
 * @Description  : 
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_state.dart';
import 'package:tcp_client/home/view/message_page/models/message_info.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class MessageListCubit extends Cubit<MessageListState> {
  MessageListCubit({
    required this.localServiceRepository,
    required this.tcpRepository
  }): super(MessageListState.empty()) {
    subscription = tcpRepository.responseStreamBroadcast.listen(_onResponse);
    Future<List<MessageInfo>>(() async {
      var pref = await SharedPreferences.getInstance();
      var userID = pref.getInt('userid');
      var msgUserList = pref.getStringList('${userID}msg');
      List<MessageInfo> msgList = [];
      if(msgUserList != null) {
        for(var user in msgUserList) {
          var targetUserID = int.parse(user);
          var history = await localServiceRepository.fetchMessageHistory(userID: targetUserID, position: 0, num: 1);
          if(history.isEmpty) {
            msgList.add(MessageInfo(targetUser: targetUserID));
          }
          else {
            msgList.add(MessageInfo(targetUser: targetUserID, message: history[0]));
          }
        }
      }
      return msgList;
    }).then((msgList) => emit(state.updateWithList(orderedNewMessages: msgList)));
  }

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  late final StreamSubscription subscription;

  void addEmptyMessageOf({required int targetUser}) async {
    if(state.messageList.any((element) => element.targetUser == targetUser)) {
      return;
    }
    var newList = [MessageInfo(targetUser: targetUser), ...state.messageList];
    emit(MessageListState(messageList: newList));
    var pref = await SharedPreferences.getInstance();
    var currentUserID = pref.getInt('userid');
    var msgUserList = pref.getStringList('${currentUserID}msg') ?? [];
    msgUserList.remove('$targetUser');
    msgUserList.insert(0, '$targetUser');
    pref.setStringList('${currentUserID}msg', msgUserList);
  }
  
  Future<void> refresh() async {
    tcpRepository.pushRequest(FetchMessageRequest(token: (await SharedPreferences.getInstance()).getInt('token')));
  }

  Future<void> _onResponse(TCPResponse response) async {
    switch(response.type) {
      case TCPResponseType.sendMessage: {
        response as SendMessageResponse;
        if(response.status == TCPResponseStatus.ok) {
          var message = await localServiceRepository.fetchMessage(msgmd5: response.md5encoded!);
          if(message != null) {
            var pref = await SharedPreferences.getInstance();
            var currentUserID = pref.getInt('userid');
            var targetUser = message.senderID == currentUserID ? message.recieverID : message.senderID;
            emit(state.updateWithSingle(messageInfo: MessageInfo(
              message: message,
              targetUser: targetUser
            )));
            var msgUserList = state.messageList.map((e) => e.targetUser.toString()).toList();
            pref.setStringList('${currentUserID}msg', msgUserList);
          }
        }
        break;
      }
      case TCPResponseType.fetchMessage: {
        response as FetchMessageResponse;
        Set<int> addedUserSet = {};
        List<MessageInfo> latestMessages = [];

        var pref = await SharedPreferences.getInstance();
        var curUser = pref.getInt('userid');
        for(var message in response.messages) {
          //Since the message can be send to or from the current user
          //it's neccessary to identify the other user's id of the message
          var targetUser = message.senderID == curUser ? message.recieverID : message.senderID;
          //Since the list is ordered descending by timestamp
          //therefore only insert to map if the target user does not exist
          if(!addedUserSet.contains(targetUser))  {
            addedUserSet.add(targetUser);
            //Create message info
            latestMessages.add(MessageInfo(
              targetUser: targetUser,
              message: message
            ));
          }
        }

        //Use the meessage list to create new state
        emit(state.updateWithList(orderedNewMessages: latestMessages));
        
        var msgUserList = state.messageList.map((e) => e.targetUser.toString()).toList();
        pref.setStringList('${curUser}msg', msgUserList);

        break;
      }
      case TCPResponseType.forwardMessage: {
        response as ForwardMessageResponse;

        var pref = await SharedPreferences.getInstance();
        var curUser = pref.getInt('userid');
        var targetUser = response.message.senderID == curUser ? 
                          response.message.recieverID : 
                          response.message.senderID;
        emit(state.updateWithSingle(
          messageInfo: MessageInfo(
            targetUser: targetUser, 
            message: response.message
          )
        ));
        var msgUserList = pref.getStringList('${curUser}msg') ?? [];
        msgUserList.remove('$targetUser');
        msgUserList.insert(0, '$targetUser');
        pref.setStringList('${curUser}msg', msgUserList);
        break;
      }
      default: break;
    }
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
