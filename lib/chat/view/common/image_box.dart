/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 17:04:20
 * @LastEditTime : 2022-10-14 17:34:12
 * @Description  : 
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tcp_client/chat/model/chat_history.dart';

class ImageBox extends StatelessWidget {
  const ImageBox({
    required this.history,
    super.key
  });

  final ChatHistory history;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Image.memory(base64Decode(history.message.contentDecoded))
    );
  }
}
