/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:50:07
 * @LastEditTime : 2022-10-13 22:05:43
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class UsernameState extends Equatable {
  const UsernameState({
    required this.userInfo,
  });

  final UserInfo userInfo;

  @override
  List<Object?> get props => [userInfo.userID, userInfo.avatarEncoded];
}
