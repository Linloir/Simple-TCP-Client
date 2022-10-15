/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:45
 * @LastEditTime : 2022-10-15 10:52:30
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:tcp_client/chat/model/chat_history.dart';
import 'package:tcp_client/chat/view/in_message_box.dart';
import 'package:tcp_client/chat/view/out_message_box.dart';
import 'package:tcp_client/common/avatar/avatar.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    required this.history,
    super.key
  });

  final ChatHistory history;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: history.type == ChatHistoryType.income ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if(history.type == ChatHistoryType.income)
          ...[
            Expanded(
              flex: 5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserAvatar(userid: history.message.senderID),
                  const SizedBox(width: 16.0,),
                  Flexible(
                    child: InMessageBox(history: history)
                  ),
                ],
              )
            ),
            const Spacer(flex: 1,),
          ],
        if(history.type == ChatHistoryType.outcome)
          ...[
            const Spacer(flex: 1,),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: OutMessageBox(history: history),
                  ),
                  const SizedBox(width: 16.0,),
                  UserAvatar(userid: history.message.senderID),
                ],
              )
            ),
          ]
      ],
    );
  }
}
