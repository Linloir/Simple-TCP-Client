/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 14:03:56
 * @LastEditTime : 2022-10-23 17:22:46
 * @Description  : 
 */

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/chat/cubit/chat_state.dart';
import 'package:tcp_client/chat/model/chat_history.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.userID,
    required this.localServiceRepository,
    required this.tcpRepository
  }): super(ChatState.empty()) {
    subscription = tcpRepository.responseStreamBroadcast.listen(_onResponse);
  }

  final int userID;
  final LocalServiceRepository localServiceRepository;
  final TCPRepository tcpRepository;
  late final StreamSubscription subscription;
  final Map<String, StreamSubscription> messageSendSubscriptionMap = {};
  final Map<String, StreamSubscription> fileFetchSubscriptionMap = {};
  final FocusNode inputNode = FocusNode();

  void unFocus() {
    inputNode.unfocus();
  }

  Future<void> addMessage(Message message) async {
    var msg = message;
    if(msg.type == MessageType.file) {
      //wait until md5 is converted
      //Emit new state
      var newHistory = ChatHistory(
        message: msg,
        type: ChatHistoryType.outcome,
        status: ChatHistoryStatus.processing
      );
      var newHistoryList = [newHistory, ...state.chatHistory];
      emit(state.copyWith(chatHistory: newHistoryList));
      var file = msg.payload!.file;
      var md5Output = AccumulatorSink<Digest>();
      ByteConversionSink md5Input = md5.startChunkedConversion(md5Output);
      await for(var bytes in file.openRead()) {
        md5Input.add(bytes);
      }
      md5Input.close();
      var loadedFile = LocalFile(
        file: file, 
        filemd5: md5Output.events.single.toString()
      );
      msg = msg.copyWith(
        payload: loadedFile
      );
    }
    //Store locally
    localServiceRepository.storeMessages([msg]);
    //Send to server
    tcpRepository.pushRequest(SendMessageRequest(
      message: msg, 
      token: (await SharedPreferences.getInstance()).getInt('token')
    ));
    //Emit new state
    var newHistory = ChatHistory(
      message: msg,
      type: ChatHistoryType.outcome,
      status: ChatHistoryStatus.sending,
      preCachedImage: msg.type == MessageType.image ? Image.memory(base64.decode(msg.contentDecoded)) : null
    );
    if(msg.type == MessageType.file) {
      //Remove mock history
      var newHistoryList = [...state.chatHistory];
      var index = newHistoryList.indexWhere((element) => element.message.contentmd5 == msg.contentmd5);
      if(index == -1) {
        return;
      }
      newHistoryList[index] = newHistory;
      emit(state.copyWith(chatHistory: newHistoryList));
    }
    else {
      var newHistoryList = [newHistory, ...state.chatHistory];
      emit(state.copyWith(chatHistory: newHistoryList));
    }
    _bindSubscriptionForSending(messageMd5: msg.contentmd5);
  }

  Future<void> fetchHistory() async {
    emit(state.copyWith(status: ChatStatus.fetching));
    //Pull 20 histories from database
    var fetchedMessages = await localServiceRepository.fetchMessageHistory(
      userID: userID, 
      position: state.chatHistory.length
    );
    var newHistories = [];
    for(var message in fetchedMessages) {
      if(state.chatHistory.any((element) => element.message.contentmd5 == message.contentmd5)) {
        continue;
      }
      var history = ChatHistory(
        message: message,
        type: message.senderID == userID ? ChatHistoryType.income : ChatHistoryType.outcome,
        status: ChatHistoryStatus.done,
        preCachedImage: message.type == MessageType.image ? Image.memory(base64.decode(message.contentDecoded)) : null
      );
      newHistories.add(history);
    }
    emit(state.copyWith(
      status: fetchedMessages.length == 20 ? ChatStatus.partial : ChatStatus.full,
      chatHistory: [...state.chatHistory, ...newHistories]
    ));
  }

  Future<void> openFile({required Message message}) async {
    if(message.type != MessageType.file) {
      return;
    }
    var file = await localServiceRepository.findFile(
      filemd5: message.filemd5!, 
      fileName: message.contentDecoded
    );
    if(file != null) {
      var newHistory = [...state.chatHistory];
      var index = newHistory.indexWhere((e) => e.message.contentmd5 == message.contentmd5);
      if(index == -1) {
        return;
      }
      newHistory[index] = newHistory[index].copyWith(status: ChatHistoryStatus.done);
      emit(state.copyWith(chatHistory: newHistory));
      OpenFile.open(file.path);
    }
    else {
      var newHistory = [...state.chatHistory];
      var index = newHistory.indexWhere((e) => e.message.contentmd5 == message.contentmd5);
      if(index == -1) {
        return;
      }
      newHistory[index] = newHistory[index].copyWith(status: ChatHistoryStatus.downloading);
      emit(state.copyWith(chatHistory: newHistory));
      fetchFile(messageMd5: message.contentmd5);
    }
  }

  Future<void> fetchFile({required String messageMd5}) async {
    // var newHistory = [...state.chatHistory];
    // var index = newHistory.indexWhere((e) => e.message.contentmd5 == messageMd5);
    // if(index != -1) {
    //   newHistory[index] = newHistory[index].copyWith(
    //     status: ChatHistoryStatus.done
    //   );
    // }
    var clonedTCPRepository = await tcpRepository.clone();
    clonedTCPRepository.pushRequest(FetchFileRequest(
      msgmd5: messageMd5, 
      token: (await SharedPreferences.getInstance()).getInt('token')
    ));
    var subscription = clonedTCPRepository.responseStreamBroadcast.listen((response) {
      if(response.type == TCPResponseType.fetchFile) {
        response as FetchFileResponse;
        if(response.status == TCPResponseStatus.ok) {
          fileFetchSubscriptionMap[messageMd5]?.cancel();
          fileFetchSubscriptionMap.remove(messageMd5);
          var newHistory = [...state.chatHistory];
          var index = newHistory.indexWhere((e) => e.message.contentmd5 == messageMd5);
          if(index != -1) {
            newHistory[index] = newHistory[index].copyWith(
              status: ChatHistoryStatus.done
            );
          }
          localServiceRepository.storeFile(tempFile: response.payload);
          emit(state.copyWith(chatHistory: newHistory));
        }
        else {
          fileFetchSubscriptionMap[messageMd5]?.cancel();
          fileFetchSubscriptionMap.remove(messageMd5);
          var newHistory = [...state.chatHistory];
          var index = newHistory.indexWhere((e) => e.message.contentmd5 == messageMd5);
          if(index != -1) {
            newHistory[index] = newHistory[index].copyWith(
              status: ChatHistoryStatus.failed
            );
          }
          emit(state.copyWith(chatHistory: newHistory));
        }
        clonedTCPRepository.dispose();
      }
    });
    fileFetchSubscriptionMap.addEntries([MapEntry(messageMd5, subscription)]);
  }

  void _onResponse(TCPResponse response) {
    if(response.type == TCPResponseType.forwardMessage) {
      response as ForwardMessageResponse;
      if(response.message.senderID == userID || response.message.recieverID == userID) {
        if(response.message.senderID == userID) {
          //Update read history
          localServiceRepository.setReadHistory(
            userid: response.message.recieverID, 
            targetid: userID, 
            timestamp: response.message.timeStamp
          );
        }
        // Message storage will be handled by home bloc listener
        //Emit new state
        var newHistory = ChatHistory(
          message: response.message,
          type: response.message.senderID == userID ? ChatHistoryType.income : ChatHistoryType.outcome,
          status: ChatHistoryStatus.done,
          preCachedImage: response.message.type == MessageType.image ? Image.memory(base64.decode(response.message.contentDecoded)) : null
        );
        var newHistoryList = [newHistory, ...state.chatHistory];
        emit(state.copyWith(chatHistory: newHistoryList));
      }
    }
    else if(response.type == TCPResponseType.fetchMessage) {
      response as FetchMessageResponse;
      List<ChatHistory> fetchedHistories = [];
      for(var message in response.messages) {
        if(message.senderID == userID || message.recieverID == userID) {
          // addMessage(message);
          var newHistory = ChatHistory(
            message: message,
            type: message.senderID == userID ? ChatHistoryType.income : ChatHistoryType.outcome,
            status: ChatHistoryStatus.done,
            preCachedImage: message.type == MessageType.image ? Image.memory(base64.decode(message.contentDecoded)) : null
          );
          fetchedHistories.insert(0, newHistory);
        }
      }
      var newHistoryList = [...fetchedHistories, ...state.chatHistory];
      emit(state.copyWith(chatHistory: newHistoryList));
    }
  }

  void _bindSubscriptionForSending({
    required String messageMd5
  }) async {
    var subscription = tcpRepository.responseStreamBroadcast.listen((response) {
      if(response.type == TCPResponseType.sendMessage) {
        response as SendMessageResponse;
        if(response.md5encoded == messageMd5) {
          messageSendSubscriptionMap[messageMd5]?.cancel();
          messageSendSubscriptionMap.remove(messageMd5);
          if(response.status == TCPResponseStatus.ok) {
            var newHistory = [...state.chatHistory];
            var index = newHistory.indexWhere((e) => e.message.contentmd5 == messageMd5);
            if(index != -1) {
              newHistory[index] = newHistory[index].copyWith(
                status: ChatHistoryStatus.done
              );
            }
            emit(state.copyWith(chatHistory: newHistory));
          }
          else {
            var newHistory = [...state.chatHistory];
            var index = newHistory.indexWhere((e) => e.message.contentmd5 == messageMd5);
            if(index != -1) {
              newHistory[index] = newHistory[index].copyWith(
                status: ChatHistoryStatus.failed
              );
            }
            emit(state.copyWith(chatHistory: newHistory));
          }
        }
      }
    });
    messageSendSubscriptionMap.addEntries([MapEntry(messageMd5, subscription)]);
  }

  @override
  Future<void> close() {
    subscription.cancel();
    for(var sub in messageSendSubscriptionMap.values) {
      sub.cancel();
    }
    return super.close();
  }
}
