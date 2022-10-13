/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 17:30:36
 * @LastEditTime : 2022-10-13 22:39:25
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';

class UserSearchResult extends Equatable {
  final UserInfo userInfo;

  const UserSearchResult({required this.userInfo});

  @override
  List<Object?> get props => [userInfo.userID];
}
