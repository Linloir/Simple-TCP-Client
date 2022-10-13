/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:02:00
 * @LastEditTime : 2022-10-13 22:26:07
 * @Description  : 
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/chat/chat_page.dart';
import 'package:tcp_client/home/cubit/home_cubit.dart';
import 'package:tcp_client/home/cubit/home_state.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_cubit.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class ContactTile extends StatelessWidget {
  const ContactTile({
    required this.userInfo,
    super.key
  });

  final UserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Stack(
        fit: StackFit.expand,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(ChatPage.route(userInfo: userInfo));
              context.read<MessageListCubit>().addEmptyMessageOf(targetUser: userInfo.userID);
              context.read<HomeCubit>().switchPage(HomePagePosition.message);
            },
          ),
          Row(
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
          ),
        ],
      ),
    );
  }
}
