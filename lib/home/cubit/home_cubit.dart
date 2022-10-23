/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:02:28
 * @LastEditTime : 2022-10-23 22:37:55
 * @Description  : 
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/cubit/home_state.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/repositories/user_repository/user_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.localServiceRepository,
    required this.tcpRepository,
    required this.pageController,
    required this.localNotificationsPlugin,
    required this.userRepository
  }): super(const HomeState(page: HomePagePosition.message, status: HomePageStatus.initializing)) {
    pageController.addListener(() {
      emit(state.copyWith(page: HomePagePosition.fromValue((pageController.page ?? 0).round())));
    });
    subscription = tcpRepository.responseStreamBroadcast.listen(_onTCPResponse);
    Future(() async {
      // var cloned = await tcpRepository.clone();
      // cloned.pushRequest(FetchMessageRequest(
      //   token: (await SharedPreferences.getInstance()).getInt('token')
      // ));
      // await for(var response in cloned.responseStreamBroadcast) {
      //   if(response.type == TCPResponseType.fetchMessage) {
      //     if(response.status == TCPResponseStatus.ok) {
      //       response as FetchMessageResponse;
      //       localServiceRepository.storeMessages(response.messages);
      //       break;
      //     }
      //   }
      // }
      // cloned.dispose();
      tcpRepository.pushRequest(FetchMessageRequest(
        token: (await SharedPreferences.getInstance()).getInt('token')
      ));
      // await for(var response in tcpRepository.responseStreamBroadcast) {
      //   if(response.type == TCPResponseType.fetchMessage) {
      //     if(response.status == TCPResponseStatus.ok) {
      //       // response as FetchMessageResponse;
      //       // localServiceRepository.storeMessages(response.messages);
      //       break;
      //     }
      //   }
      // }
    });
  }

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  final PageController pageController;
  final UserRepository userRepository;
  late final StreamSubscription subscription;
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  void switchPage(HomePagePosition newPage) {
    pageController.animateToPage(
      newPage.value, 
      duration: const Duration(milliseconds: 500), 
      curve: Curves.easeInOutCubicEmphasized
    );
  }

  void _onTCPResponse(TCPResponse response) async {
    if(response.status == TCPResponseStatus.err) {
      return;
    }
    switch(response.type) {
      case TCPResponseType.forwardMessage: {
        response as ForwardMessageResponse;
        await localServiceRepository.storeMessages([response.message]);
        var curUser = (await SharedPreferences.getInstance()).getInt('userid');
        if(response.message.senderID != curUser) {
          //Push notification via flutter local notification
          const androidNotificationDetails = AndroidNotificationDetails(
            '0',
            'New Messages',
            channelDescription: 'New messages',
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            enableLights: true,
            visibility: NotificationVisibility.private
          );
          const iosNotificationDetails = DarwinNotificationDetails();
          const linuxNotificationDetails = LinuxNotificationDetails();
          const notificationDetails = NotificationDetails(
            android: androidNotificationDetails,
            iOS: iosNotificationDetails,
            macOS: iosNotificationDetails,
            linux: linuxNotificationDetails
          );
          var userName = userRepository.getUserInfo(userid: response.message.senderID).userName;
          await localNotificationsPlugin.show(
            response.message.contentmd5.hashCode,
            'New Message',
            '$userName: ${response.message.contentDecoded}',
            notificationDetails,
            payload: response.message.contentmd5
          );
        }
        break;
      }
      case TCPResponseType.fetchMessage: {
        response as FetchMessageResponse;
        await localServiceRepository.storeMessages(response.messages);
        emit(state.copyWith(status: HomePageStatus.done));
        if(response.messages.isNotEmpty) {
          tcpRepository.pushRequest(AckFetchRequest(
            timeStamp: response.messages[0].timeStamp, 
            token: (await SharedPreferences.getInstance()).getInt('token')
          ));
        }
        break;
      }
      default: {
        break;
      }
    }
  }

  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
