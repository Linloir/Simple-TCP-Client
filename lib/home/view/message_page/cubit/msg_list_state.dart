/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:37:49
 * @LastEditTime : 2022-10-23 20:50:19
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/home/view/message_page/models/message_info.dart';

class MessageListState extends Equatable {
  final List<MessageInfo> messageList;
  final Map<int, int> unreadCnt;

  const MessageListState({
    required this.messageList,
    required this.unreadCnt
  });

  static MessageListState empty() => const MessageListState(messageList: [], unreadCnt: {});

  MessageListState copyWith({
    List<MessageInfo>? messageList,
    Map<int, int>? unreadCnt
  }) {
    return MessageListState(
      messageList:  messageList ?? this.messageList,
      unreadCnt: unreadCnt ?? this.unreadCnt
    );
  }

  // MessageListState updateWithSingle({
  //   required MessageInfo messageInfo
  // }) {
  //   var newList = <MessageInfo>[messageInfo];
  //   for(var msgInfo in messageList) {
  //     if(msgInfo.targetUser == messageInfo.targetUser) {
  //       continue;
  //     }
  //     newList.add(msgInfo);
  //   }
  //   return MessageListState(messageList: newList);
  // }

  // MessageListState updateWithList({
  //   required List<MessageInfo> orderedNewMessages
  // }) {
  //   var newList = <MessageInfo>[];
  //   Set<int> addedUsers = {};
  //   var insertListIndex = 0;
  //   var origListIndex = 0;
  //   while(
  //     insertListIndex < orderedNewMessages.length && 
  //     origListIndex < messageList.length
  //   ) {
  //     if(addedUsers.contains(orderedNewMessages[insertListIndex].targetUser)) {
  //       insertListIndex += 1;
  //       continue;
  //     }
  //     if(addedUsers.contains(messageList[origListIndex].targetUser)) {
  //       origListIndex += 1;
  //       continue;
  //     }
  //     if(
  //       (messageList[origListIndex].message?.timeStamp ?? 0) > 
  //       (orderedNewMessages[insertListIndex].message?.timeStamp ?? 0)
  //     ) {
  //       newList.add(messageList[origListIndex]);
  //       addedUsers.add(messageList[origListIndex].targetUser);
  //       origListIndex += 1;
  //       continue;
  //     }
  //     else {
  //       newList.add(orderedNewMessages[insertListIndex]);
  //       addedUsers.add(orderedNewMessages[insertListIndex].targetUser);
  //       insertListIndex += 1;
  //       continue;
  //     }
  //   }
  //   //Add the messages left
  //   while(origListIndex < messageList.length) {
  //     if(addedUsers.contains(messageList[origListIndex].targetUser)) {
  //       origListIndex += 1;
  //       continue;
  //     }
  //     newList.add(messageList[origListIndex]);
  //     addedUsers.add(messageList[origListIndex].targetUser);
  //     origListIndex += 1;
  //     continue;
  //   }
  //   while(insertListIndex < orderedNewMessages.length) {
  //     if(addedUsers.contains(orderedNewMessages[insertListIndex].targetUser)) {
  //       insertListIndex += 1;
  //       continue;
  //     }
  //     newList.add(orderedNewMessages[insertListIndex]);
  //     addedUsers.add(orderedNewMessages[insertListIndex].targetUser);
  //     insertListIndex += 1;
  //     continue;
  //   }
    
  //   return MessageListState(messageList: newList);
  // }

  // MessageListState deleteOf({
  //   required MessageInfo messageInfo
  // }) {
  //   var newList = <MessageInfo>[];
  //   for(var msgInfo in messageList) {
  //     if(msgInfo == messageInfo) {
  //       continue;
  //     }
  //     newList.add(msgInfo);
  //   }
  //   return MessageListState(messageList: newList);
  // }

  @override
  List<Object> get props => [...unreadCnt.entries, ...messageList];
}
