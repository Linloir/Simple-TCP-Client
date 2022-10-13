/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:38:31
 * @LastEditTime : 2022-10-13 16:12:53
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_state.dart';
import 'package:tcp_client/home/view/message_page/models/message_info.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class MessageListCubit extends Cubit<MessageListState> {
  MessageListCubit({
    required this.localServiceRepository,
    required this.tcpRepository
  }): super(MessageListState.empty()) {
    tcpRepository.responseStreamBroadcast.listen(_onResponse);
  }

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

  void addEmptyMessageOf({required UserInfo user}) {
    if(state.messageList.any((element) => element.userInfo.userID == user.userID)) {
      return;
    }
    var newList = [MessageInfo(userInfo: user)];
    emit(MessageListState(messageList: newList..addAll(state.messageList)));
  }

  Future<void> _onResponse(TCPResponse response) async {
    switch(response.type) {
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
            var targetUserInfo = await localServiceRepository.fetchUserInfoViaID(userid: targetUser);
            //TODO: Maybe need to add API in tcp repository to fetch user info via id
            targetUserInfo ??= UserInfo(userid: targetUser, username: targetUser.toString());
            //Create message info
            latestMessages.add(MessageInfo(
              userInfo: targetUserInfo,
              message: message
            ));
          }
        }

        //Use the meessage list to create new state
        emit(state.updateWithList(orderedNewMessages: latestMessages));

        break;
      }
      case TCPResponseType.forwardMessage: {
        response as ForwardMessageResponse;

        var pref = await SharedPreferences.getInstance();
        var curUser = pref.getInt('userid');
        var targetUser = response.message.senderID == curUser ? 
                          response.message.recieverID : 
                          response.message.senderID;
        var targetUserInfo = await localServiceRepository.fetchUserInfoViaID(userid: targetUser);
        //TODO: Maybe need to add API in tcp repository to fetch user info via id
        targetUserInfo ??= UserInfo(userid: targetUser, username: targetUser.toString());
        emit(state.updateWithSingle(
          messageInfo: MessageInfo(
            userInfo: targetUserInfo, 
            message: response.message
          )
        ));
        break;
      }
      default: break;
    }
  }
}
