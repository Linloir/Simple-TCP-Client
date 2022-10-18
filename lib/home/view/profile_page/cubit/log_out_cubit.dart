/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 10:54:57
 * @LastEditTime : 2022-10-17 20:51:45
 * @Description  : 
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/view/profile_page/cubit/log_out_state.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class LogOutCubit extends Cubit<LogOutStatus> {
  LogOutCubit({
    required this.tcpRepository
  }): super(LogOutStatus.none) {
    subscription = tcpRepository.responseStreamBroadcast.listen(_onResponse);
  }

  final TCPRepository tcpRepository;
  late final StreamSubscription subscription;

  void _onResponse(TCPResponse response) {
    if(response.type == TCPResponseType.logout) {
      if(response.status == TCPResponseStatus.ok) {
        emit(LogOutStatus.done);
      }
      else {
        emit(LogOutStatus.none);
      }
    }
  }

  void onLogout() async {
    emit(LogOutStatus.processing);
    tcpRepository.pushRequest(LogoutRequest(token: (await SharedPreferences.getInstance()).getInt('token')));
  }

  //Override dispose to cancel the subscription
  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
