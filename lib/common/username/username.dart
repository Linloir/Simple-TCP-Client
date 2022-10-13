/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 22:05:12
 * @LastEditTime : 2022-10-13 22:21:42
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/common/username/cubit/username_cubit.dart';
import 'package:tcp_client/common/username/cubit/username_state.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class UserNameText extends StatelessWidget {
  const UserNameText({
    required this.userid,
    this.fontWeight = FontWeight.normal,
    super.key
  });

  final int userid;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsernameCubit, UsernameState>(
      bloc: UsernameCubit(
        userid: userid,
        userRepository: context.read<UserRepository>()
      ),
      builder: (context, state) {
        return Text(
          state.userInfo.userName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: fontWeight
          ),
        );
      }
    );
  }
}
