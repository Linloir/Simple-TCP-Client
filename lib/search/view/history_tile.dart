/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:41:49
 * @LastEditTime : 2022-10-23 10:30:06
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:tcp_client/common/avatar/avatar.dart';
import 'package:tcp_client/common/username/username.dart';
import 'package:tcp_client/repositories/common_models/message.dart';

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    required this.userID,
    required this.message,
    super.key
  });

  final int userID;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 24.0
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatar(userid: userID),
            const SizedBox(width: 12,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 0
                    ),
                    child: UserNameText(userid: userID, fontWeight: FontWeight.bold,)
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0
                    ),
                    child: Text(
                      message.contentDecoded,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 0
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  getTimeStamp(message.timeStamp)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTimeStamp(int timeStamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    var weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    //If date is today, return time
    if(date.day == DateTime.now().day) {
      return '${date.hour}:${date.minute}';
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