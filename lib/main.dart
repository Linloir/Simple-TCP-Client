/*
 * @Author       : Linloir
 * @Date         : 2022-10-10 08:04:53
 * @LastEditTime : 2022-10-20 17:58:56
 * @Description  : 
 */
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tcp_client/home/home_page.dart';
import 'package:tcp_client/initialization/cubit/initialization_cubit.dart';
import 'package:tcp_client/initialization/cubit/initialization_state.dart';
import 'package:tcp_client/initialization/initialization_page.dart';
import 'package:tcp_client/login/login_page.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  sqfliteFfiInit();

  //The code below is for desktop platforms only-------------------------
  WidgetsFlutterBinding.ensureInitialized();
  
  // Must add this line.
  await windowManager.ensureInitialized();

  //Get preferred window size
  var pref = await SharedPreferences.getInstance();
  var width = pref.getDouble('windowWidth');
  var height = pref.getDouble('windowHeight');
  var posX = pref.getDouble('windowPosX');
  var posY = pref.getDouble('windowPosY');
  WindowOptions windowOptions = WindowOptions(
    size: Size(width ?? 800, height ?? 600),
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    if(posX != null && posY != null) {
      await windowManager.setPosition(Offset(posX, posY));
    }
    await windowManager.show();
    await windowManager.focus();
  });

  //---------------------------------------------------------------------

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WindowListener {
  // This widget is the root of your application.
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void onWindowMove() {
    EasyDebounce.debounce(
      'WindowMove', 
      const Duration(milliseconds: 50), 
      () async {
        var pref = await SharedPreferences.getInstance();
        var pos = await windowManager.getPosition();
        pref.setDouble('windowPosX', pos.dx);
        pref.setDouble('windowPosY', pos.dy);
      }
    );
    super.onWindowMove();
  }

  @override
  void onWindowResize() {
    EasyDebounce.debounce(
      'WindowResize', 
      const Duration(milliseconds: 50), 
      () async {
        var pref = await SharedPreferences.getInstance();
        var size = await windowManager.getSize();
        pref.setDouble('windowWidth', size.width);
        pref.setDouble('windowHeight', size.height);
      }
    );
    super.onWindowResize();
  }

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