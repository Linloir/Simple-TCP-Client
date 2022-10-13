/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 17:09:25
 * @LastEditTime : 2022-10-13 23:25:20
 * @Description  : 
 */

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';
import 'package:tcp_client/search/cubit/search_state.dart';
import 'package:tcp_client/search/model/history_result.dart';
import 'package:tcp_client/search/model/user_result.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required this.localServiceRepository,
    required this.tcpRepository
  }): super(const SearchState.empty()) {
    subscription = tcpRepository.responseStreamBroadcast.listen(_onResponse);
  }

  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  late final StreamSubscription subscription;

  void onKeyChanged(String newKey) {
    EasyDebounce.debounce(
      'Search',
      const Duration(milliseconds: 500),
      () => _performSearch(newKey)
    );
  }

  Future<void> _performSearch(String newKey) async {
    tcpRepository.pushRequest(SearchUserRequest(
      username: newKey, 
      token: (await SharedPreferences.getInstance()).getInt('token')
    ));
    var histories = await localServiceRepository.findMessages(pattern: newKey);
    var currentUserID = (await SharedPreferences.getInstance()).getInt('userid');
    var historyResults = histories.map((msg) {
      var targetID = msg.senderID == currentUserID ? msg.recieverID : msg.senderID;
      return HistorySearchResult(contact: targetID, message: msg);
    }).toList();
    emit(state.copyWith(historyResults: historyResults));
  }

  Future<void> _onResponse(TCPResponse response) async {
    switch(response.type) {
      case TCPResponseType.searchUser: {
        response as SearchUserResponse;
        //TODO: Maybe server search should be ambigious
        var userInfo = response.userInfo;
        emit(state.copyWith(
          userResults: [
            if(userInfo != null) UserSearchResult(userInfo: userInfo)
          ]
        ));
        break;
      }
      default: break;
    }
  }

  //Override dispose to cancel the subscription
  @override
  Future<void> close() {
    subscription.cancel();
    return super.close();
  }
}
