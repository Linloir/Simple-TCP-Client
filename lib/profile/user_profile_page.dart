/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 17:04:44
 * @LastEditTime : 2022-10-14 12:11:26
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/common/avatar/avatar.dart';
import 'package:tcp_client/common/username/username.dart';
import 'package:tcp_client/profile/cubit/user_profile_cubit.dart';
import 'package:tcp_client/profile/view/add_contact_button.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.userID,
    required this.localServiceRepository,
    required this.tcpRepository,
    required this.userRepository,
    super.key
  });

  static Route<void> route({
    required int userID,
    required LocalServiceRepository localServiceRepository,
    required TCPRepository tcpRepository,
    required UserRepository userRepository
  }) => MaterialPageRoute<void>(builder: (context) => ProfilePage(
    userID: userID,
    localServiceRepository: localServiceRepository,
    tcpRepository: tcpRepository,
    userRepository: userRepository,
  ));

  final int userID;
  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>.value(
          value: userRepository,
        ),
        RepositoryProvider<LocalServiceRepository>.value(
          value: localServiceRepository,
        ),
        RepositoryProvider<TCPRepository>.value(
          value: tcpRepository,
        )
      ],
      child: BlocProvider<UserProfileCubit>(
        create: (context) => UserProfileCubit(
          userID: userID,
          tcpRepository: tcpRepository,
        ),
        child: Scaffold(
          appBar: AppBar(),
          body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserAvatar(userid: userID, size: 96,),
                const SizedBox(height: 48,),
                UserNameText(
                  userid: userID, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 22,
                  alignment: Alignment.center,
                ),
                const SizedBox(height: 48,),
                AddContactButton(userID: userID)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
