/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 11:05:08
 * @LastEditTime : 2022-10-13 23:02:55
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
import 'package:tcp_client/repositories/user_repository/user_repository.dart';
import 'package:tcp_client/search/search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.localServiceRepository,
    required this.tcpRepository,
    super.key
  });

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

  static Route<void> route({
    required LocalServiceRepository localServiceRepository,
    required TCPRepository tcpRepository
  }) => MaterialPageRoute<void>(builder: (context) => HomePage(
    localServiceRepository: localServiceRepository,
    tcpRepository: tcpRepository,
  ));

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(
            localServiceRepository: localServiceRepository,
            tcpRepository: tcpRepository
          ),
        ),
        RepositoryProvider<LocalServiceRepository>.value(value: localServiceRepository),
        RepositoryProvider<TCPRepository>.value(value: tcpRepository),
      ],
      child: MultiBlocProvider(
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
        child: HomePageView(),
      ),
    );
  }
}

class HomePageView extends StatelessWidget {
  HomePageView({super.key});

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen:(previous, current) => current.page != previous.page,
      listener: (context, state) {
        _controller.animateToPage(
          state.page.value, 
          duration: const Duration(milliseconds: 375), 
          curve: Curves.easeInOutCubicEmphasized
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return Text(
                state.page.literal,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                Navigator.of(context).push(SearchPage.route(
                  localServiceRepository: context.read<LocalServiceRepository>(), 
                  tcpRepository: context.read<TCPRepository>(), 
                  userRepository: context.read<UserRepository>()
                ));
              },
            )
          ],
        ),
        body: Center(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder:(context, state) => PageView(
              controller: _controller,
              onPageChanged: (value) => context.read<HomeCubit>().switchPage(HomePagePosition.fromValue(value)),
              children: const [
                MessagePage(),
                ContactPage()
              ],
            ),
          ),
        ),
      ),
    );
  }
}