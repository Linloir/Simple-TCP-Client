/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:16
 * @LastEditTime : 2022-10-13 16:29:57
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    required this.userInfo,
    super.key
  });

  final UserInfo userInfo;

  static Route<void> route({required UserInfo userInfo}) => MaterialPageRoute<void>(builder: (context) => ChatPage(userInfo: userInfo,));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userInfo.userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        )
      ),
    );
  }
}
