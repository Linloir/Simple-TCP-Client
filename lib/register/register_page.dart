/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 17:36:38
 * @LastEditTime : 2022-10-12 17:50:42
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
import 'package:formz/formz.dart';
import 'package:tcp_client/home/home_page.dart';
import 'package:tcp_client/register/bloc/register_cubit.dart';
import 'package:tcp_client/register/bloc/register_state.dart';
import 'package:tcp_client/register/view/register_form.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({
    required this.localServiceRepository,
    required this.tcpRepository,
    super.key
  });

  static Route<void> route({
    required LocalServiceRepository localServiceRepository,
    required TCPRepository tcpRepository
  }) => MaterialPageRoute<void>(builder: (context) => RegisterPage(
    localServiceRepository: localServiceRepository,
    tcpRepository: tcpRepository
  ));

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Register Failed'))
              );
            }
            else if(state.status == FormzStatus.submissionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Register Successed'))
              );
              Future.delayed(const Duration(seconds: 1)).then((_) {
                Navigator.of(context).pushReplacement(HomePage.route());
              });
            }
          },
          listenWhen: (previous, current) => previous.status != current.status,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
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

