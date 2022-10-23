/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 17:04:12
 * @LastEditTime : 2022-10-22 23:06:38
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/chat/cubit/chat_cubit.dart';
import 'package:tcp_client/chat/model/chat_history.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';

class TextBox extends StatelessWidget {
  const TextBox({
    required this.history,
    super.key
  });

  final ChatHistory history;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 0.0,
          vertical: 6.0
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if(history.type == ChatHistoryType.outcome)
              ...[
                if(history.status == ChatHistoryStatus.sending)
                  ...[
                    SizedBox(
                      height: 12.0,
                      width: 12.0,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.5),
                        strokeWidth: 2.0,
                      ),
                    ),
                    const SizedBox(width: 12.0,),
                  ],
                if(history.status == ChatHistoryStatus.failed)
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
                    const SizedBox(width: 6.0,),
                  ],
                if(history.status == ChatHistoryStatus.done)
                  ...[
                    Icon(
                      Icons.check_rounded,
                      color: Colors.white.withOpacity(0.5),
                      size: 18,
                    ),
                    const SizedBox(width: 8.0,),
                  ],
              ],
              Flexible(
                child: Text(
                  history.message.contentDecoded,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 16,
                    color: history.type == ChatHistoryType.income ? Colors.grey[900] : Colors.white
                  ),
                ),
              ),
          ]
        )
      ),
    );
  }
}
