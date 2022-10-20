/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 21:50:14
 * @LastEditTime : 2022-10-20 18:03:54
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
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
  }

  final UserRepository userRepository;

  void onFetchedUserInfo(UserInfo userInfo) {
    if(userInfo.userID == state.userInfo.userID) {
      emit(AvatarState(
        userInfo: userInfo
      ));
    }
  }
}