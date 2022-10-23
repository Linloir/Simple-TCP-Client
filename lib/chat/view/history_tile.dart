/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:45
 * @LastEditTime : 2022-10-23 10:55:42
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/chat/cubit/chat_cubit.dart';
import 'package:tcp_client/chat/model/chat_history.dart';
import 'package:tcp_client/chat/view/in_message_box.dart';
import 'package:tcp_client/chat/view/out_message_box.dart';
import 'package:tcp_client/common/avatar/avatar.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';

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
                  UserAvatar(userid: history.message.senderID, size: 42,),
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
                    child: history.message.type == MessageType.image ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if(history.type == ChatHistoryType.outcome && history.status == ChatHistoryStatus.sending)
                          ...[
                            SizedBox(
                              height: 12.0,
                              width: 12.0,
                              child: CircularProgressIndicator(
                                color: Colors.grey.withOpacity(0.5),
                                strokeWidth: 2.0,
                              ),
                            ),
                            const SizedBox(width: 12.0,),
                          ],
                        if(history.type == ChatHistoryType.outcome && history.status == ChatHistoryStatus.done)
                          ...[
                            Icon(
                              Icons.check_rounded,
                              color: Colors.grey.withOpacity(0.5),
                              size: 18,
                            ),
                            const SizedBox(width: 8.0,),
                          ],
                        if(history.type == ChatHistoryType.outcome && history.status == ChatHistoryStatus.failed)
                          ...[
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  child: Icon(
                                    Icons.error_rounded,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 18,
                                  ),
                                  onTap: () async {
                                    context.read<ChatCubit>().tcpRepository.pushRequest(SendMessageRequest(
                                      message: history.message, 
                                      token: (await SharedPreferences.getInstance()).getInt('token')
                                    ));
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0,),
                          ],
                        OutMessageBox(history: history),
                      ],
                    ) : OutMessageBox(history: history),
                  ),
                  const SizedBox(width: 16.0,),
                  UserAvatar(userid: history.message.senderID, size: 42,),
                ],
              )
            ),
          ]
      ],
    );
  }
}
