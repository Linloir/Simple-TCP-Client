/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 17:04:20
 * @LastEditTime : 2022-10-23 10:52:45
 * @Description  : 
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/chat/cubit/chat_cubit.dart';
import 'package:tcp_client/chat/model/chat_history.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';

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
