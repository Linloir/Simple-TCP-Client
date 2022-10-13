/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 11:05:08
 * @LastEditTime : 2022-10-13 16:55:48
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/home/cubit/home_cubit.dart';
import 'package:tcp_client/home/cubit/home_state.dart';
import 'package:tcp_client/home/view/contact_page/contact_page.dart';
import 'package:tcp_client/home/view/contact_page/cubit/contact_cubit.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_cubit.dart';
import 'package:tcp_client/home/view/message_page/mesage_page.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class HomePage extends StatelessWidget {
  HomePage({
    required this.localServiceRepository,
    required this.tcpRepository,
    super.key
  });

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

  final PageController _controller = PageController();

  static Route<void> route({
    required LocalServiceRepository localServiceRepository,
    required TCPRepository tcpRepository
  }) => MaterialPageRoute<void>(builder: (context) => HomePage(
    localServiceRepository: localServiceRepository,
    tcpRepository: tcpRepository,
  ));

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MessageListCubit>(
          create: (context) => MessageListCubit(
            localServiceRepository: localServiceRepository, 
            tcpRepository: tcpRepository
          ),
        ),
        BlocProvider<ContactCubit>(
          create: (context) => ContactCubit(
            localServiceRepository: localServiceRepository,
            tcpRepository: tcpRepository
          ),
        ),
        BlocProvider<HomeCubit>(
          create: (context) => HomeCubit(
            localServiceRepository: localServiceRepository,
            tcpRepository: tcpRepository
          ),
        )
      ],
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen:(previous, current) => current.page != previous.page,
        listener: (context, state) {
          _controller.animateToPage(
            state.page.value, 
            duration: const Duration(milliseconds: 375), 
            curve: Curves.easeInOutCubicEmphasized
          );
        },
        child: Scaffold(
          body: PageView(
            controller: _controller,
            children: const [
              MessagePage(),
              ContactPage()
            ],
          ),
        ),
      )
      
    );
  }
}
