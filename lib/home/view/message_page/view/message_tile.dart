/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 13:17:52
 * @LastEditTime : 2022-10-23 20:49:21
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/chat/chat_page.dart';
import 'package:tcp_client/common/avatar/avatar.dart';
import 'package:tcp_client/common/username/username.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_cubit.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({
    required this.userID,
    this.message,
    required int? unreadCnt,
    super.key
  }): unreadCnt = unreadCnt ?? 0;

  final int userID;
  final Message? message;
  final int unreadCnt;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Stack(
        fit: StackFit.expand,
        children: [
          InkWell(
            onTap: () {
              if(message != null) {
                context.read<LocalServiceRepository>().setReadHistory(
                  userid: message!.recieverID == userID ? message!.senderID : message!.recieverID, 
                  targetid: userID, 
                  timestamp: message!.timeStamp
                );
              }
              context.read<MessageListCubit>().clearUnread(targetID: userID);
              Navigator.of(context).push(ChatPage.route(
                userRepository: context.read<UserRepository>(),
                localServiceRepository: context.read<LocalServiceRepository>(),
                tcpRepository: context.read<TCPRepository>(),
                userID: userID
              ));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 24.0
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IgnorePointer(
                  child: UserAvatar(userid: userID),
                ),
                // if(userInfo.avatarEncoded != null && userInfo.avatarEncoded!.isEmpty) 
                //   Container(
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(5.0),
                //       border: Border.all(
                //         color: Colors.grey[700]!,
                //         width: 1.0
                //       )
                //     ),
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(5.0),
                //       child: OverflowBox(
                //         alignment: Alignment.center,
                //         child: FittedBox(
                //           fit: BoxFit.fitWidth,
                //           child: Image.memory(base64Decode(userInfo.avatarEncoded!)),
                //         ),
                //       )
                //     ),
                //   ),
                // if(userInfo.avatarEncoded == null || userInfo.avatarEncoded!.isEmpty)
                //   Container(
                //     color: Colors.grey,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(5.0),
                //       border: Border.all(
                //         color: Colors.grey[700]!,
                //         width: 1.0
                //       )
                //     ),
                //   ),
                const SizedBox(width: 16,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 6,),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 0
                        ),
                        child: IgnorePointer(
                          child: UserNameText(userid: userID, fontWeight: FontWeight.bold,),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0
                        ),
                        child: IgnorePointer(
                          child: Text(
                            message?.type == MessageType.image ? '[Image]' : message?.contentDecoded ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6,),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if(message != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8.0
                        ),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: IgnorePointer(
                            child: Text(
                              getTimeStamp(message!.timeStamp)
                            ),
                          ),
                        ),
                      ),
                    if(unreadCnt != 0)
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 8.0
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.blue.withOpacity(0.9)
                        ),
                        child: Text(
                          '${unreadCnt > 99 ? '99+' : unreadCnt}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getTimeStamp(int timeStamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    var weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    //If date is today, return time
    if(date.day == DateTime.now().day) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    //If date is yda, return 'yda'
    if(date.day == DateTime.now().day - 1) {
      return 'yda ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    //If date is within this week, return the weekday in english
    if(date.weekday < DateTime.now().weekday) {
      return weekdays[date.weekday - 1];
    }
    //Otherwise return the date in english
    return '${date.month}/${date.day}';
  }
}
