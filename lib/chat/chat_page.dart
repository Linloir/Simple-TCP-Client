/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:16
 * @LastEditTime : 2022-10-22 21:30:04
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/chat/cubit/chat_cubit.dart';
import 'package:tcp_client/chat/cubit/chat_state.dart';
import 'package:tcp_client/chat/view/history_tile.dart';
import 'package:tcp_client/chat/view/input_box/input_box.dart';
import 'package:tcp_client/common/username/username.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    required this.userRepository,
    required this.localServiceRepository,
    required this.tcpRepository,
    required this.userID,
    super.key
  });

  final int userID;
  final UserRepository userRepository;
  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

  static Route<void> route({
    required UserRepository userRepository,
    required LocalServiceRepository localServiceRepository,
    required TCPRepository tcpRepository,
    required int userID
  }) => MaterialPageRoute<void>(builder: (context) => ChatPage(
    userID: userID,
    userRepository: userRepository,
    localServiceRepository: localServiceRepository,
    tcpRepository: tcpRepository,
  ));

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserRepository>.value(
      value: userRepository,
      child: BlocProvider<ChatCubit>(
        create: (context) =>  ChatCubit(
          userID: userID,
          localServiceRepository: localServiceRepository,
          tcpRepository: tcpRepository
        ),
        child: Scaffold(
          appBar: AppBar(
            title: UserNameText(
              userid: userID,
              fontWeight: FontWeight.bold,
            )
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      reverse: true,
                      itemBuilder: (context, index) {
                        if(index == state.chatHistory.length) {
                          //Load more
                          context.read<ChatCubit>().fetchHistory();
                          //Show loading indicator
                          return const Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 2.0,
                              ),
                            ),
                          );
                        }
                        else {
                          //Return history tile
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8
                            ),
                            child: HistoryTile(
                              history: state.chatHistory[index],
                            ),
                          );
                        }
                      },
                      itemCount: state.status == ChatStatus.full ? state.chatHistory.length : state.chatHistory.length + 1,
                    );
                  },
                ),
              ),
              InputBox()
            ]
          ),
        )
      ),
    );
  }
}
