/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 15:06:30
 * @LastEditTime : 2022-10-12 18:03:29
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:tcp_client/home/home_page.dart';
import 'package:tcp_client/login/bloc/login_cubit.dart';
import 'package:tcp_client/login/bloc/login_state.dart';
import 'package:tcp_client/login/view/login_form.dart';
import 'package:tcp_client/register/register_page.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    required this.localServiceRepository,
    required this.tcpRepository,
    super.key
  });

  static Route<void> route({
    required LocalServiceRepository localServiceRepository,
    required TCPRepository tcpRepository
  }) => MaterialPageRoute<void>(builder: (context) => LoginPage(
    localServiceRepository: localServiceRepository,
    tcpRepository: tcpRepository
  ));

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        localServiceRepository: localServiceRepository,
        tcpRepository: tcpRepository
      ),
      child: Scaffold(
        body: BlocListener<LoginCubit, LoginState>(
          listener:(context, state) {
            if(state.status == FormzStatus.submissionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login Failed'))
              );
            }
            else if(state.status == FormzStatus.submissionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login Successed'))
              );
              Future.delayed(const Duration(seconds: 1)).then((_) {
                Navigator.of(context).pushReplacement(HomePage.route());
              });
            }
          },
          listenWhen: (previous, current) => previous.status != current.status,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: const LoginPanel()
                  )
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Does not have an account?'),
                        const SizedBox(width: 8,),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(RegisterPage.route(localServiceRepository: localServiceRepository, tcpRepository: tcpRepository)), 
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            foregroundColor: MaterialStateProperty.all(Colors.blue[800])
                          ),
                          child: const Text('Register'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPanel extends StatelessWidget {
  const LoginPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        LoginForm()
      ],
    );
  }
}

