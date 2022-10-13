/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:38:31
 * @LastEditTime : 2022-10-13 22:27:29
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

  void addEmptyMessageOf({required int targetUser}) {
    if(state.messageList.any((element) => element.targetUser == targetUser)) {
      return;
    }
    var newList = [MessageInfo(targetUser: targetUser)];
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
            //Create message info
            latestMessages.add(MessageInfo(
              targetUser: targetUser,
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
        emit(state.updateWithSingle(
          messageInfo: MessageInfo(
            targetUser: targetUser, 
            message: response.message
          )
        ));
        break;
      }
      default: break;
    }
  }
}
