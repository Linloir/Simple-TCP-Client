/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 08:54:32
 * @LastEditTime : 2022-10-14 11:30:59
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/profile/cubit/user_profile_state.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit({
    required this.userID,
    required this.tcpRepository
  }): super(const UserProfileState(status: ContactStatus.none)) {
    updateContactStatus();
  }

  final int userID;
  final TCPRepository tcpRepository;

  Future<void> updateContactStatus() async {
    if(userID == (await SharedPreferences.getInstance()).getInt('userid')) {
      emit(const UserProfileState(status: ContactStatus.none));
    }
    var clonedTCPRepository = await tcpRepository.clone();
    clonedTCPRepository.pushRequest(FetchContactRequest(token: (await SharedPreferences.getInstance()).getInt('token')));
    await for(var response in clonedTCPRepository.responseStreamBroadcast) {
      if(response.type == TCPResponseType.fetchContact) {
        response as FetchContactResponse;
        if(response.addedContacts.any((element) => element.userID == userID)) {
          emit(const UserProfileState(status: ContactStatus.isContact));
        }
        else if(response.pendingContacts.any((element) => element.userID == userID)) {
          emit(const UserProfileState(status: ContactStatus.pendingReply));
        }
        else {
          emit(const UserProfileState(status: ContactStatus.notContact));
        }
        break;
      }
    }
    clonedTCPRepository.dispose();
  }

  Future<void> addContact() async {
    emit(const UserProfileState(status: ContactStatus.consulting));
    var clonedTCPRepository = await tcpRepository.clone();
    clonedTCPRepository.pushRequest(AddContactRequest(
      userid: userID, 
      token: (await SharedPreferences.getInstance()).getInt('token')
    ));
    await for(var response in clonedTCPRepository.responseStreamBroadcast) {
      if(response.type == TCPResponseType.addContact) {
        break;
      }
    }
    clonedTCPRepository.dispose();
    updateContactStatus();
  }
}