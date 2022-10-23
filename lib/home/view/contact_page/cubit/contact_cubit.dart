/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:01:45
 * @LastEditTime : 2022-10-23 12:09:26
 * @Description  : 
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/home/view/contact_page/cubit/contact_state.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit({
    required this.localServiceRepository,
    required this.tcpRepository
  }): super(ContactState.empty()) {
    subscription = tcpRepository.responseStreamBroadcast.listen(_onResponse);
    updateContacts();
    timer = Timer.periodic(const Duration(seconds: 60), (timer) {updateContacts();});
  }

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  late final StreamSubscription subscription;
  late final Timer timer;

  void _onResponse(TCPResponse response) {
    switch(response.type) {
      case TCPResponseType.fetchContact: {
        response as FetchContactResponse;
        emit(ContactState(
          contacts: response.addedContacts,
          pending: response.pendingContacts,
          requesting: response.requestingContacts
        ));
        break;
      }
      default: break;
    }
  }

  Future<void> updateContacts() async {
    tcpRepository.pushRequest(FetchContactRequest(token: (await SharedPreferences.getInstance()).getInt('token')));
  }

  //Override dispose to cancel the subscription
  @override
  Future<void> close() {
    subscription.cancel();
    timer.cancel();
    return super.close();
  }
}
