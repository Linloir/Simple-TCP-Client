/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 17:36:38
 * @LastEditTime : 2022-10-23 22:12:12
 * @Description  : 
 */
/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 15:06:30
 * @LastEditTime : 2022-10-12 17:34:10
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:formz/formz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/home_page.dart';
import 'package:tcp_client/register/cubit/register_cubit.dart';
import 'package:tcp_client/register/cubit/register_state.dart';
import 'package:tcp_client/register/view/register_form.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({
    required this.localServiceRepository,
    required this.tcpRepository,
    required this.localNotificationsPlugin,
    super.key
  });

  static Route<void> route({
    required LocalServiceRepository localServiceRepository,
    required TCPRepository tcpRepository,
    required FlutterLocalNotificationsPlugin localNotificationsPlugin,
  }) => MaterialPageRoute<void>(builder: (context) => RegisterPage(
    localServiceRepository: localServiceRepository,
    tcpRepository: tcpRepository,
    localNotificationsPlugin: localNotificationsPlugin,
    
  ));

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(
        localServiceRepository: localServiceRepository,
        tcpRepository: tcpRepository
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.blue[800],
        ),
        body: BlocListener<RegisterCubit, RegisterState>(
          listener:(context, state) {
            if(state.status == FormzStatus.submissionFailure) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Register Failed${state.info.isNotEmpty ? ': ${state.info}' : ''}'))
              );
            }
            else if(state.status == FormzStatus.submissionSuccess) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Register Successed'))
              );
              Future<int>(() async {
                await Future.delayed(const Duration(seconds: 1));
                var pref = await SharedPreferences.getInstance();
                return pref.getInt('userid')!;
              }).then((userID) {
                Navigator.of(context).pushAndRemoveUntil(HomePage.route(
                  userID: userID,
                  localServiceRepository: localServiceRepository,
                  tcpRepository: tcpRepository,
                  localNotificationsPlugin: localNotificationsPlugin
                ), (route) => false);
              });
            }
          },
          listenWhen: (previous, current) => previous.status != current.status,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
                  const Expanded(
                    flex: 6,
                    child: RegisterPanel()
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPanel extends StatelessWidget {
  const RegisterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        RegisterForm()
      ],
    );
  }
}

