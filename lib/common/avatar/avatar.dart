/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:49:53
 * @LastEditTime : 2022-10-20 13:46:16
 * @Description  : 
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/common/avatar/cubit/avatar_cubit.dart';
import 'package:tcp_client/common/avatar/cubit/avatar_state.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.userid, 
    this.size = 48,
    this.onTap,
    super.key
  });

  final int userid;
  final double size;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvatarCubit, AvatarState>(
      bloc: AvatarCubit(
        userid: userid,
        userRepository: context.read<UserRepository>()
      ),
      builder: (context, state) {
        if(state.userInfo.avatarEncoded == null) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.grey[850]!.withOpacity(0.15))]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      state.userInfo.userName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24 * (size / 48),
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 5.0, color: Colors.white.withOpacity(0.15))]
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        else {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.grey[850]!.withOpacity(0.15))]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.memory(base64.decode(state.userInfo.avatarEncoded!)),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
