/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:50:14
 * @LastEditTime : 2022-10-20 17:02:19
 * @Description  : 
 */

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:tcp_client/common/avatar/cubit/avatar_state.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class AvatarCubit extends Cubit<AvatarState> {
  AvatarCubit({
    required int userid,
    required this.userRepository
  }): super(AvatarState(userInfo: userRepository.getUserInfo(userid: userid))) 
  {
    userRepository.userInfoStreamBroadcast.listen(onFetchedUserInfo);
    emit(AvatarState(
      userInfo: state.userInfo, 
      preCachedAvatar: state.userInfo.avatarEncoded == null ? null : 
                        Image.memory(base64.decode(state.userInfo.avatarEncoded!))
    ));
  }

  final UserRepository userRepository;

  void onFetchedUserInfo(UserInfo userInfo) {
    if(userInfo.userID == state.userInfo.userID) {
      emit(AvatarState(
        userInfo: userInfo, 
        preCachedAvatar: userInfo.avatarEncoded == null ? null : 
                          Image.memory(base64.decode(userInfo.avatarEncoded!))
      ));
    }
  }
}