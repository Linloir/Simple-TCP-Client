/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 23:36:12
 * @LastEditTime : 2022-10-23 22:10:44
 * @Description  : 
 */

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/common/avatar/avatar.dart';
import 'package:tcp_client/common/username/username.dart';
import 'package:tcp_client/home/cubit/home_cubit.dart';
import 'package:tcp_client/home/view/profile_page/cubit/log_out_cubit.dart';
import 'package:tcp_client/home/view/profile_page/cubit/log_out_state.dart';
import 'package:tcp_client/home/view/profile_page/view/log_out_button.dart';
import 'package:tcp_client/login/login_page.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({
    required this.userID,
    super.key
  });

  static Route<void> route({
    required int userID,
  }) => MaterialPageRoute<void>(builder: (context) => MyProfilePage(
    userID: userID,
  ));

  final int userID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogOutCubit>(
      create: (context) => LogOutCubit(tcpRepository: context.read<TCPRepository>()),
      child: BlocListener<LogOutCubit, LogOutStatus>(
        listenWhen: (previous, current) => current == LogOutStatus.done || (previous == LogOutStatus.processing && current == LogOutStatus.none),
        listener: (context, state) {
          if(state == LogOutStatus.none) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Log out failed'))
            );
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out'))
            );
            Future.delayed(const Duration(seconds: 1)).then((_) {
              Navigator.of(context).pushAndRemoveUntil(LoginPage.route(
                localServiceRepository: context.read<LocalServiceRepository>(), 
                tcpRepository: context.read<TCPRepository>(),
                localNotificationsPlugin: context.read<HomeCubit>().localNotificationsPlugin
              ), (route) => false);
            });
          }
        },
        child: BlocBuilder<LogOutCubit, LogOutStatus>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(
                    userid: userID, 
                    size: 96,
                    onTap: () async {
                      var homeCubit = context.read<HomeCubit>();
                      var userInfo = context.read<UserRepository>().getUserInfo(userid: userID);
                      homeCubit.localServiceRepository.pickFile(FileType.image).then((img) async {
                        if(img != null) {
                          var pref = await SharedPreferences.getInstance();
                          var token = pref.getInt('token');
                          var newRequest = ModifyProfileRequest(
                            userInfo: UserInfo(
                              userid: userID,
                              username: userInfo.userName,
                              avatar: base64.encode(await img.readAsBytes())
                            ),
                            token: token
                          );
                          homeCubit.tcpRepository.pushRequest(newRequest);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 48,),
                  UserNameText(
                    userid: userID, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 22,
                    alignment: Alignment.center,
                  ),
                  const SizedBox(height: 48,),
                  const LogoutButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
    
  }
}
