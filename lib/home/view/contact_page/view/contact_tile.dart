/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:02:00
 * @LastEditTime : 2022-10-14 11:59:48
 * @Description  : 
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/chat/chat_page.dart';
import 'package:tcp_client/common/avatar/avatar.dart';
import 'package:tcp_client/common/username/username.dart';
import 'package:tcp_client/home/cubit/home_cubit.dart';
import 'package:tcp_client/home/cubit/home_state.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_cubit.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

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
              Navigator.of(context).push(ChatPage.route(
                userRepository: context.read<UserRepository>(),
                localServiceRepository: context.read<LocalServiceRepository>(),
                tcpRepository: context.read<TCPRepository>(),
                userID: userInfo.userID
              ));
              context.read<MessageListCubit>().addEmptyMessageOf(targetUser: userInfo.userID);
              context.read<HomeCubit>().switchPage(HomePagePosition.message);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Row(
              children: [
                UserAvatar(userid: userInfo.userID),
                const SizedBox(width: 12,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0
                    ),
                    child: UserNameText(userid: userInfo.userID,)
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
