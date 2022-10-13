/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 13:17:52
 * @LastEditTime : 2022-10-13 14:57:14
 * @Description  : 
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({
    required this.userInfo,
    this.message,
    super.key
  });

  final UserInfo userInfo;
  final Message? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 24.0
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(userInfo.avatarEncoded != null && userInfo.avatarEncoded!.isEmpty) 
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.grey[700]!,
                    width: 1.0
                  )
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Image.memory(base64Decode(userInfo.avatarEncoded!)),
                    ),
                  )
                ),
              ),
            if(userInfo.avatarEncoded == null || userInfo.avatarEncoded!.isEmpty)
              Container(
                color: Colors.grey,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.grey[700]!,
                    width: 1.0
                  )
                ),
              ),
            const SizedBox(width: 12,),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 0
                    ),
                    child: Text(
                      userInfo.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0
                    ),
                    child: Text(
                      message?.contentDecoded ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
            if(message != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 0
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    getTimeStamp(message!.timeStamp)
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
    //If date is yesterday, return 'yesterday'
    if(date.day == DateTime.now().day - 1) {
      return 'yesterday';
    }
    //If date is within this week, return the weekday in english
    if(date.weekday < DateTime.now().weekday) {
      return weekdays[date.weekday - 1];
    }
    //Otherwise return the date in english
    return '${date.month}/${date.day}';
  }
}
