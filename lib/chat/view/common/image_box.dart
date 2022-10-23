/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 17:04:20
 * @LastEditTime : 2022-10-22 23:05:24
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
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 200, maxHeight: 150),
              child: history.preCachedImage ?? Image.memory(base64Decode(history.message.contentDecoded)),
            ),
            Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.1),
                  onTap: (){},
                )
              ),
          ]
        ),
      ),
    );
  }
}
