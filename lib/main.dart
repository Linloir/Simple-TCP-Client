/*
 * @Author       : Linloir
 * @Date         : 2022-10-10 08:04:53
 * @LastEditTime : 2022-10-12 17:55:07
 * @Description  : 
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tcp_client/home/home_page.dart';
import 'package:tcp_client/initialization/cubit/initialization_cubit.dart';
import 'package:tcp_client/initialization/cubit/initialization_state.dart';
import 'package:tcp_client/initialization/initialization_page.dart';
import 'package:tcp_client/login/login_page.dart';

void main() {
  sqfliteFfiInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashPage(),
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InitializationCubit>(
      create: (context) {
        return InitializationCubit(
          serverAddress: '127.0.0.1', 
          serverPort: 20706
        );
      },
      child: BlocListener<InitializationCubit, InitializationState>(
        listener: (context, state) {
          if(state.isDone) {
            Future.delayed(const Duration(seconds: 1)).then((_) async {
              if((await SharedPreferences.getInstance()).getInt('userid') != null) {
                Navigator.of(context).pushReplacement(HomePage.route());
              }
              else {
                Navigator.of(context).pushReplacement(LoginPage.route(
                  localServiceRepository: state.localServiceRepository!,
                  tcpRepository: state.tcpRepository!
                ));
              }
            });
          }
        },
        child: const InitializePage(),
      )
    );
  }
}