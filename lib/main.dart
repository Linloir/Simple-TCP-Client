/*
 * @Author       : Linloir
 * @Date         : 2022-10-10 08:04:53
 * @LastEditTime : 2022-10-22 20:43:39
 * @Description  : 
 */
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/home_page.dart';
import 'package:tcp_client/initialization/cubit/initialization_cubit.dart';
import 'package:tcp_client/initialization/cubit/initialization_state.dart';
import 'package:tcp_client/initialization/initialization_page.dart';
import 'package:tcp_client/login/login_page.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
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
          serverAddress: '192.168.43.155', 
          serverPort: 20706
        );
      },
      child: BlocListener<InitializationCubit, InitializationState>(
        listener: (context, state) {
          if(state.isDone) {
            Future<int?>(() async {
              await Future.delayed(const Duration(seconds: 1));
              var pref = await SharedPreferences.getInstance();
              return pref.getInt('userid');
            }).then((userID) {
              if(userID != null) {
                Navigator.of(context).pushReplacement(HomePage.route(
                  userID: userID,
                  localServiceRepository: state.localServiceRepository!,
                  tcpRepository: state.tcpRepository!
                ));
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