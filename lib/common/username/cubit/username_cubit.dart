/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:50:14
 * @LastEditTime : 2022-10-13 22:05:52
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
import 'package:tcp_client/common/username/cubit/username_state.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class UsernameCubit extends Cubit<UsernameState> {
  UsernameCubit({
    required int userid,
    required this.userRepository
  }): super(UsernameState(userInfo: userRepository.getUserInfo(userid: userid))) {
    userRepository.userInfoStreamBroadcast.listen(onFetchedUserInfo);
  }

  final UserRepository userRepository;

  void onFetchedUserInfo(UserInfo userInfo) {
    if(userInfo.userID == state.userInfo.userID) {
      emit(UsernameState(userInfo: userInfo));
    }
  }
}