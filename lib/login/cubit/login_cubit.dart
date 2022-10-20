/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 15:38:07
 * @LastEditTime : 2022-10-20 20:51:09
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/login/cubit/login_state.dart';
import 'package:tcp_client/login/models/password.dart';
import 'package:tcp_client/login/models/username.dart';
import 'package:tcp_client/repositories/common_models/useridentity.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required this.localServiceRepository,
    required this.tcpRepository
  }): super(const LoginState());

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

  void onPasswordChange(Password password) {
    emit(state.copyWith(
      status: Formz.validate([state.username, password]),
      password: password
    ));
  }

  Future<void> onUsernameChange(Username username) async {
    emit(state.copyWith(
      status: Formz.validate([username, state.password]),
      username: username,
    ));
    var userinfo = await localServiceRepository.fetchUserInfoViaUsername(username: username.value);
    emit(state.copyWith(
      avatar: userinfo?.avatarEncoded
    ));
  }

  Future<void> onSubmission() async {
    if(state.status.isValidated) {
      emit(state.copyWith(
        status: FormzStatus.submissionInProgress,
        info: ""
      ));
      tcpRepository.pushRequest(LoginRequest(
        identity: UserIdentity(
          username: state.username.value,
          password: state.password.value
        ), 
        token: (await SharedPreferences.getInstance()).getInt('token')
      ));
      await for(var response in tcpRepository.responseStreamBroadcast) {
        if(response.type == TCPResponseType.login) {
          if(response.status == TCPResponseStatus.ok) {
            var pref = await SharedPreferences.getInstance();
            pref.setInt('userid', (response as LoginResponse).userInfo!.userID);
            emit(state.copyWith(
              status: FormzStatus.submissionSuccess
            ));
          }
          else {
            emit(state.copyWith(
              status: FormzStatus.submissionFailure,
              info: response.info?.replaceAll('Exception: ', ''),
            ));
          }
          break;
        }
      }
    }
  }
}
