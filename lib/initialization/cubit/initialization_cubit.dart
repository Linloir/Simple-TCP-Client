/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 09:56:04
 * @LastEditTime : 2022-10-17 21:11:30
 * @Description  : 
 */

import 'package:bloc/bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/initialization/cubit/initialization_state.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class InitializationCubit extends Cubit<InitializationState> {
  InitializationCubit({
    required String serverAddress,
    required int serverPort
  }): super(const InitializationState.init()) {
    TCPRepository? tcpRepository;
    LocalServiceRepository? localServiceRepository;
    Future(() async {
      localServiceRepository = await LocalServiceRepository.create(
        databaseFilePath: '${
          (await getApplicationDocumentsDirectory()).path
        }/LChatClient/.data/database.db'
      );
    }).then((_) {
      emit(state.copyWith(
        databaseStatus: InitializationStatus.done,
        localServiceRepository: localServiceRepository
      ));
    });
    Future(() async {
      tcpRepository = await TCPRepository.create(serverAddress: serverAddress, serverPort: serverPort);
    }).then((_) {
      emit(state.copyWith(
        mainSocketStatus: InitializationStatus.done,
        tcpRepository: tcpRepository
      ));
    });
    Future(() async {
      var tempConnection = await TCPRepository.create(serverAddress: serverAddress, serverPort: serverPort);
      var pref = await SharedPreferences.getInstance();
      var tokenid = pref.getInt('token');
      tempConnection.pushRequest(CheckStateRequest(token: tokenid));
      await for(var response in tempConnection.responseStreamBroadcast) {
        if(response.type == TCPResponseType.token) {
          pref.setInt('token', (response as SetTokenReponse).token);
        }
        else if(response.type == TCPResponseType.checkState) {
          if(response.status == TCPResponseStatus.ok) {
            pref.setInt('userid', (response as CheckStateResponse).userInfo!.userID);
          }
          else {
            pref.remove('userid');
          }
          break;
        }
      }
      tempConnection.dispose();
    }).then((_) {
      emit(state.copyWith(
        tokenStatus: InitializationStatus.done
      ));
    });
  }

  InitializationCubit.failed(): super(const InitializationState.init());
}