/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 20:18:14
 * @LastEditTime : 2022-10-23 12:06:33
 * @Description  : Repository to cache user info
 */

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class UserRepository {
  final Map<int, UserInfo> users = {};
  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;

  final StreamController<UserInfo> _userInfoStreamController = StreamController();
  Stream<UserInfo>? _userInfoStreamBroadcast;
  Stream<UserInfo> get userInfoStreamBroadcast {
    _userInfoStreamBroadcast ??= _userInfoStreamController.stream.asBroadcastStream();
    return _userInfoStreamBroadcast!;
  }

  UserRepository({
    required this.localServiceRepository,
    required this.tcpRepository
  }) {
    tcpRepository.responseStreamBroadcast.listen(_onResponse);
  }

  Future<void> _onResponse(TCPResponse response) async {
    if(response.type == TCPResponseType.profile && response.status == TCPResponseStatus.ok) {
      response as GetProfileResponse;
      users.update(response.userInfo!.userID, (value) => response.userInfo!, ifAbsent: () => response.userInfo!);
      _userInfoStreamController.add(response.userInfo!);
      localServiceRepository.storeUserInfo(userInfo: response.userInfo!);
    }
    else if(response.type == TCPResponseType.modifyProfile && response.status == TCPResponseStatus.ok) {
      response as ModifyProfileResponse;
      users.update(response.userInfo!.userID, (value) => response.userInfo!, ifAbsent: () => response.userInfo!);
      _userInfoStreamController.add(response.userInfo!);
      localServiceRepository.storeUserInfo(userInfo: response.userInfo!);
    }
    else if(response.type == TCPResponseType.fetchContact && response.status == TCPResponseStatus.ok) {
      response as FetchContactResponse;
      for(var user in response.addedContacts) {
        users.update(
          user.userID, 
          (value) => user,
          ifAbsent: () => user
        );
        localServiceRepository.storeUserInfo(userInfo: user);
        _userInfoStreamController.add(user);
      }
      for(var user in response.pendingContacts) {
        users.update(
          user.userID, 
          (value) => user,
          ifAbsent: () => user
        );
        localServiceRepository.storeUserInfo(userInfo: user);
        _userInfoStreamController.add(user);
      }
      for(var user in response.requestingContacts) {
        users.update(
          user.userID, 
          (value) => user,
          ifAbsent: () => user
        );
        localServiceRepository.storeUserInfo(userInfo: user);
        _userInfoStreamController.add(user);
      }
    }
  }

  //Fetch user info
  //1. Check if the user info is in the map
  //   if so, return the user, otherwise consult the database
  //2. If the database has the user info
  //   add it to the map and stream, otherwise consult the tcp repository
  //3. Pass the control to tcp response handler
  UserInfo getUserInfo({required int userid}) {
    if(users.containsKey(userid)) {
      return users[userid]!;
    }
    Future<UserInfo?>(() async {
      //Consult the database for info
      return await localServiceRepository.fetchUserInfoViaID(userid: userid);
    }).then((userInfo) async {
      if(userInfo == null) {
        //Consult the tcp server for info
        tcpRepository.pushRequest(GetProfileRequest(
          userid: userid, 
          token: (await SharedPreferences.getInstance()).getInt('token')
        ));
      }
      else {
        //Add to map
        users.update(userid, (value) => userInfo, ifAbsent: () => userInfo);
        //Push to stream
        _userInfoStreamController.add(userInfo);
      }
    });
    //Return a mock userinfo
    return UserInfo(
      userid: userid,
      username: userid.toString(),
    );
  }
}
