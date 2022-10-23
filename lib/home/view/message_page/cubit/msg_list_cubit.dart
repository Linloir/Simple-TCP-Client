/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:38:31
 * @LastEditTime : 2022-10-23 20:43:56
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
    }).then((msgList) async {
      //get new message list
      var newList = updateWithList(orderedNewMessages: msgList);
      //get unread message count
      var curUser = (await SharedPreferences.getInstance()).getInt('userid');
      Map<int, int> unreadCnt = {};
      for(var msg in newList) {
        var cnt = await localServiceRepository.getUnreadCount(
          userid: curUser!, 
          targetid: msg.targetUser
        );
        unreadCnt.update(msg.targetUser, (value) => cnt, ifAbsent: () => cnt,);
      }
      //Emit new state
      if(!isClosed) {
        emit(state.copyWith(messageList: newList, unreadCnt: unreadCnt));
      }
    });
  }

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  late final StreamSubscription subscription;

  void addEmptyMessageOf({required int targetUser}) async {
    if(state.messageList.any((element) => element.targetUser == targetUser)) {
      return;
    }
    var newList = [MessageInfo(targetUser: targetUser), ...state.messageList];
    emit(state.copyWith(messageList: newList));
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

  void clearUnread({required int targetID}) {
    var unreadCnt = state.unreadCnt;
    unreadCnt.update(targetID, (value) => 0, ifAbsent: () => 0,);
    emit(state.copyWith(unreadCnt: unreadCnt));
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
            var newList = updateWithSingle(messageInfo: MessageInfo(
              message: message,
              targetUser: targetUser
            ));
            emit(state.copyWith(messageList: newList));
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

        Map<int, int> unreadCnt = state.unreadCnt;
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
          //Add to unreadCnt
          var lastReadTime = await localServiceRepository.fetchReadHistory(
            userid: curUser!, 
            targetid: targetUser
          );
          if(lastReadTime < message.timeStamp) {
            unreadCnt.update(targetUser, (value) => value + 1, ifAbsent: () => 1,);
          }
        }

        //Use the meessage list to create new state
        var newMessageList = updateWithList(orderedNewMessages: latestMessages);
        //Emit new state
        if(!isClosed) {
          emit(state.copyWith(messageList: newMessageList, unreadCnt: unreadCnt));
        }
        
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
        var newList = updateWithSingle(
          messageInfo: MessageInfo(
            targetUser: targetUser, 
            message: response.message
          )
        );
        var unreadCnt = state.unreadCnt;
        var lastReadTime = await localServiceRepository.fetchReadHistory(
          userid: curUser!,
          targetid: targetUser
        );
        if(lastReadTime < response.message.timeStamp) {
          unreadCnt.update(targetUser, (value) => value + 1, ifAbsent: () => 1,);
        }
        else {
          unreadCnt.update(targetUser, (value) => 0, ifAbsent: () => 0,);
        }
        if(!isClosed) {
          emit(state.copyWith(messageList: newList, unreadCnt: unreadCnt));
        }
        var msgUserList = pref.getStringList('${curUser}msg') ?? [];
        msgUserList.remove('$targetUser');
        msgUserList.insert(0, '$targetUser');
        pref.setStringList('${curUser}msg', msgUserList);
        break;
      }
      default: break;
    }
  }

  List<MessageInfo> updateWithSingle({
    required MessageInfo messageInfo
  }) {
    var newList = <MessageInfo>[messageInfo];
    for(var msgInfo in state.messageList) {
      if(msgInfo.targetUser == messageInfo.targetUser) {
        continue;
      }
      newList.add(msgInfo);
    }
    return newList;
  }

  List<MessageInfo> updateWithList({
    required List<MessageInfo> orderedNewMessages
  }) {
    var newList = <MessageInfo>[];
    Set<int> addedUsers = {};
    var insertListIndex = 0;
    var origListIndex = 0;
    while(
      insertListIndex < orderedNewMessages.length && 
      origListIndex < state.messageList.length
    ) {
      if(addedUsers.contains(orderedNewMessages[insertListIndex].targetUser)) {
        insertListIndex += 1;
        continue;
      }
      if(addedUsers.contains(state.messageList[origListIndex].targetUser)) {
        origListIndex += 1;
        continue;
      }
      if(
        (state.messageList[origListIndex].message?.timeStamp ?? 0) > 
        (orderedNewMessages[insertListIndex].message?.timeStamp ?? 0)
      ) {
        newList.add(state.messageList[origListIndex]);
        addedUsers.add(state.messageList[origListIndex].targetUser);
        origListIndex += 1;
        continue;
      }
      else {
        newList.add(orderedNewMessages[insertListIndex]);
        addedUsers.add(orderedNewMessages[insertListIndex].targetUser);
        insertListIndex += 1;
        continue;
      }
    }
    //Add the messages left
    while(origListIndex < state.messageList.length) {
      if(addedUsers.contains(state.messageList[origListIndex].targetUser)) {
        origListIndex += 1;
        continue;
      }
      newList.add(state.messageList[origListIndex]);
      addedUsers.add(state.messageList[origListIndex].targetUser);
      origListIndex += 1;
      continue;
    }
    while(insertListIndex < orderedNewMessages.length) {
      if(addedUsers.contains(orderedNewMessages[insertListIndex].targetUser)) {
        insertListIndex += 1;
        continue;
      }
      newList.add(orderedNewMessages[insertListIndex]);
      addedUsers.add(orderedNewMessages[insertListIndex].targetUser);
      insertListIndex += 1;
      continue;
    }
    
    return newList;
  }

  List<MessageInfo> deleteOf({
    required MessageInfo messageInfo
  }) {
    var newList = <MessageInfo>[];
    for(var msgInfo in state.messageList) {
      if(msgInfo == messageInfo) {
        continue;
      }
      newList.add(msgInfo);
    }
    return newList;
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
