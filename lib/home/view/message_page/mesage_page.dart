/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 11:05:18
 * @LastEditTime : 2022-10-13 16:11:24
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_cubit.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_state.dart';
import 'package:tcp_client/home/view/message_page/view/message_tile.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageListCubit, MessageListState>(
      builder: (context, state) {
        return ListView.separated(
          itemBuilder: (context, index) {
            return MessageTile(
              userInfo: state.messageList[index].userInfo,
              message: state.messageList[index].message,
            );
          }, 
          separatorBuilder: (context, index) {
            return const Divider(
              height: 0.5,
            );
          }, 
          itemCount: state.messageList.length
        );
      }
    );
  }
}
