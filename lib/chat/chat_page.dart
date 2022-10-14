/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:16
 * @LastEditTime : 2022-10-14 11:58:34
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: Scaffold(
        appBar: AppBar(
          title: UserNameText(
            userid: userID,
            fontWeight: FontWeight.bold,
          )
        ),
      ),
    );
  }
}
