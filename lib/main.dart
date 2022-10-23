/*
 * @Author       : Linloir
 * @Date         : 2022-10-10 08:04:53
 * @LastEditTime : 2022-10-23 22:26:44
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
  FlutterLocalNotificationsPlugin();

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid = 
    AndroidInitializationSettings('@mipmap/ic_launcher');
  const  DarwinInitializationSettings initializationSettingsDarwin = 
    DarwinInitializationSettings();
  const  LinuxInitializationSettings initializationSettingsLinux = 
    LinuxInitializationSettings(
      defaultActionName: 'Open notification'
    );
  const InitializationSettings initializationSettings = 
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux
    );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings
  );
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
      title: 'LChatClient',
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
          serverAddress: 'chat.linloir.cn', 
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
                  tcpRepository: state.tcpRepository!,
                  localNotificationsPlugin: flutterLocalNotificationsPlugin
                ));
              }
              else {
                Navigator.of(context).pushReplacement(LoginPage.route(
                  localServiceRepository: state.localServiceRepository!,
                  tcpRepository: state.tcpRepository!,
                  localNotificationsPlugin: flutterLocalNotificationsPlugin
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