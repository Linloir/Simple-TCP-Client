/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:41:41
 * @LastEditTime : 2022-10-13 23:26:46
 * @Description  : 
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    required this.userInfo,
    super.key
  });

  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  child: Image.memory(base64.decode(userInfo.avatarEncoded!)),
                ),
              )
            ),
          ),
        if(userInfo.avatarEncoded == null || userInfo.avatarEncoded!.isEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: Colors.grey[700]!,
                width: 1.0
              )
            ),
          ),
        const SizedBox(width: 12,),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0
            ),
            child: Text(
              userInfo.userName,
              style: const TextStyle(
                fontSize: 18.0
              ),
            ),
          )
        ),
      ],
    );
  }
}
