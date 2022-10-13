/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:02:28
 * @LastEditTime : 2022-10-13 23:02:04
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
import 'package:tcp_client/home/cubit/home_state.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.localServiceRepository,
    required this.tcpRepository,
  }): super(const HomeState(page: HomePagePosition.message));

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

  void switchPage(HomePagePosition newPage) {
    emit(state.copyWith(page: newPage));
  }
}
