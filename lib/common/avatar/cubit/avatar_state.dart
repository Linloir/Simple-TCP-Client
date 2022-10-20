/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:50:07
 * @LastEditTime : 2022-10-20 16:51:11
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class AvatarState extends Equatable {
  const AvatarState({
    required this.userInfo,
    this.preCachedAvatar
  });

  final UserInfo userInfo;
  final Image? preCachedAvatar;

  @override
  List<Object?> get props => [userInfo.userID, userInfo.avatarEncoded, preCachedAvatar];
}
