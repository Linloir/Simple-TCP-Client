/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 13:49:28
 * @LastEditTime : 2022-10-23 10:07:32
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:tcp_client/chat/model/chat_history.dart';
import 'package:tcp_client/chat/view/common/file_box.dart';
import 'package:tcp_client/chat/view/common/image_box.dart';
import 'package:tcp_client/chat/view/common/text_box.dart';
import 'package:tcp_client/repositories/common_models/message.dart';

class OutMessageBox extends StatelessWidget {
  const OutMessageBox({
    required this.history,
    super.key
  });

  final ChatHistory history;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedContainer(
          key: ValueKey(history.message.contentmd5),
          duration: const Duration(milliseconds: 375),
          padding: history.message.type == MessageType.image ? 
            const EdgeInsets.all(0) : 
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.zero
            ),
            boxShadow: [BoxShadow(blurRadius: 5.0, color: Colors.grey.withOpacity(0.2))]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if(history.message.type == MessageType.file)
                FileBox(history: history),
              if(history.message.type == MessageType.image)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.zero
                  ),
                  child: ImageBox(history: history),
                ),
              if(history.message.type == MessageType.plaintext)
                TextBox(history: history),
              if(history.message.type != MessageType.image)
                ...[
                  const SizedBox(height: 4.0,),
                  Text(
                    _getTimeStamp(history.message.timeStamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[200],
                    ),
                  )
                ],
            ],
          ),
        ),
        if(history.message.type == MessageType.image)
          ...[
            const SizedBox(height: 4.0,),
            Text(
              _getTimeStamp(history.message.timeStamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ]
      ]
    );
  }

  String _getTimeStamp(int timeStamp) {
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
      return '${weekdays[date.weekday - 1]} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    //Otherwise return the date in english
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}