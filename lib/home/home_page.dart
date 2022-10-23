/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 11:05:08
 * @LastEditTime : 2022-10-23 22:37:02
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/cubit/home_cubit.dart';
import 'package:tcp_client/home/cubit/home_state.dart';
import 'package:tcp_client/home/view/contact_page/contact_page.dart';
import 'package:tcp_client/home/view/contact_page/cubit/contact_cubit.dart';
import 'package:tcp_client/home/view/message_page/cubit/msg_list_cubit.dart';
import 'package:tcp_client/home/view/message_page/mesage_page.dart';
import 'package:tcp_client/home/view/profile_page/profile_page.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';
import 'package:tcp_client/search/search_page.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatelessWidget with WindowListener {
  const HomePage({
    required this.userID,
    required this.localServiceRepository,
    required this.tcpRepository,
    required this.localNotificationsPlugin,
    super.key
  });
  //TODO: listen to file storage

  final int userID;
  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  static Route<void> route({
    required int userID,
    required LocalServiceRepository localServiceRepository,
    required TCPRepository tcpRepository,
    required FlutterLocalNotificationsPlugin localNotificationsPlugin,
  }) => MaterialPageRoute<void>(builder: (context) => HomePage(
    userID: userID,
    localServiceRepository: localServiceRepository,
    tcpRepository: tcpRepository,
    localNotificationsPlugin: localNotificationsPlugin,
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
              tcpRepository: tcpRepository,
              pageController: PageController(),
              localNotificationsPlugin: localNotificationsPlugin,
              userRepository: context.read<UserRepository>()
            ),
          )
        ],
        child: HomePageView(userID: userID,),
      ),
    );
  }
}

class HomePageView extends StatelessWidget {
  const HomePageView({
    required this.userID,
    super.key
  });

  final int userID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return state.page == HomePagePosition.contact ? 
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () async {
                    context.read<TCPRepository>().pushRequest(FetchContactRequest(
                      token: (await SharedPreferences.getInstance()).getInt('token')
                    ));
                  },
                ) : Container();
            },
          ),
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
      body: BlocBuilder<HomeCubit, HomeState>(
        builder:(context, state) => Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: PageView(
                  controller: context.read<HomeCubit>().pageController,
                  children: [
                    MessagePage(),
                    const ContactPage(),
                    MyProfilePage(userID: userID)
                  ],
                ),
              ),
            ),
            if(state.status == HomePageStatus.initializing)
              Positioned.fill(
                child: AbsorbPointer(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800]!.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0)
                      ),
                      height: 200,
                      width: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4.0,
                          ),
                          SizedBox(height: 16.0,),
                          Text(
                            'Fetching Messages',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ]
        ),
      ),
      bottomNavigationBar: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.message_rounded),
              icon: Icon(Icons.message_outlined),
              label: 'Message'
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.contacts_rounded),
              icon: Icon(Icons.contacts_outlined),
              label: 'Contacts'
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.person_rounded),
              icon: Icon(Icons.person_outline_rounded),
              label: 'Me'
            ),
          ],
          currentIndex: state.page.value,
          onTap: (value) => context.read<HomeCubit>().switchPage(HomePagePosition.fromValue(value))
        ),
      )
    );
  }
}