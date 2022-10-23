/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 11:05:18
 * @LastEditTime : 2022-10-23 20:47:33
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_cubit.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_state.dart';
import 'package:tcp_client/home/view/message_page/view/message_tile.dart';

class MessagePage extends StatelessWidget {
  MessagePage({super.key});

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageListCubit, MessageListState>(
      builder: (context, state) {
        return SmartRefresher(
          controller: _refreshController,
          onRefresh: () async {
            await context.read<MessageListCubit>().refresh();
            _refreshController.refreshCompleted();
          },
          child: ListView.separated(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (context, index) {
              return MessageTile(
                userID: state.messageList[index].targetUser,
                message: state.messageList[index].message,
                unreadCnt: state.unreadCnt[state.messageList[index].targetUser],
              );
            }, 
            separatorBuilder: (context, index) {
              return const Divider(
                height: 0.5,
              );
            }, 
            itemCount: state.messageList.length
          ),
        );
      }
    );
  }
}
