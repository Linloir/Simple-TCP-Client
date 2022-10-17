/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:02:28
 * @LastEditTime : 2022-10-17 17:00:45
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:tcp_client/home/cubit/home_state.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.localServiceRepository,
    required this.tcpRepository,
    required this.pageController
  }): super(const HomeState(page: HomePagePosition.message)) {
    pageController.addListener(() {
      emit(state.copyWith(page: HomePagePosition.fromValue((pageController.page ?? 0).round())));
    });
  }

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  final PageController pageController;

  void switchPage(HomePagePosition newPage) {
    pageController.animateToPage(
      newPage.value, 
      duration: const Duration(milliseconds: 500), 
      curve: Curves.easeInOutCubicEmphasized
    );
  }
}
