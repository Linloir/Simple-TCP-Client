/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 09:42:05
 * @LastEditTime : 2022-10-22 17:46:28
 * @Description  : TCP repository
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';

class TCPRepository {
  TCPRepository._internal({
    required Socket socket,
    required String remoteAddress,
    required int remotePort
  }): _socket = socket, _remoteAddress = remoteAddress, _remotePort = remotePort {
    Future(() async {
      while(true) {
        try{
          await for(var response in _socket!) {
            _pullResponse(response);
            await Future.delayed(const Duration(microseconds: 0));
          }
          break;
        } catch(e) {
          _socket?.close();
          _socket = null;
          while(true) {
            try{
              _socket = await Socket.connect(remoteAddress, remotePort);
              break;
            } catch (e) {
              continue;
            }
          }
        }
      }
      // _responseRawStreamController.close();
      // _payloadPullStreamController.close();
      // _payloadRawStreamController.close();
      // _responseStreamController.close();
      // _requestStreamController.close();
    });
    //This future never ends, would that be bothersome?
    Future(() async {
      TCPRequest? failedRequest;
      while(true) {
        try{
          if(failedRequest != null) {
            await Future.doWhile(() async {
              await Future.delayed(const Duration(microseconds: 0));
              return _socket == null;
            });
            await _socket!.addStream(failedRequest.stream);
          }
          await for(var request in _requestStreamController.stream) {
            failedRequest = request;
            await Future.doWhile(() async {
              await Future.delayed(const Duration(microseconds: 0));
              return _socket == null;
            });
            await _socket!.addStream(request.stream);
            failedRequest = null;
          }
          break;
        } catch (e) {
          _socket?.close();
          _socket = null;
          while(true) {
            try{
              _socket = await Socket.connect(remoteAddress, remotePort);
              break;
            } catch (e) {
              continue;
            }
          }
        }
      }
    });
    Future(() async {
      var responseQueue = StreamQueue(_responseRawStreamController.stream);
      var payloadQueue = StreamQueue(_payloadRawStreamController.stream);
      while(await Future<bool>(() => !_responseRawStreamController.isClosed && !_payloadRawStreamController.isClosed)) {
        var response = await responseQueue.next;
        var payload = await payloadQueue.next;
        await _pushResponse(responseBytes: response, tempFile: payload);
      }
      responseQueue.cancel();
      payloadQueue.cancel();
    }).onError((error, stackTrace) {_socket?.close();});
  }

  static Future<TCPRepository> create({
    required String serverAddress,
    required int serverPort
  }) async {
    Socket socket;
    while(true) {
      try{
        socket = await Socket.connect(serverAddress, serverPort);
        break;
      } catch (e) {
        continue;
      }
    }
    return TCPRepository._internal(
      socket: socket, 
      remoteAddress: serverAddress, 
      remotePort: serverPort
    );
  }

  Future<TCPRepository> clone() async {
    return await TCPRepository.create(
      serverAddress: _remoteAddress, 
      serverPort: _remotePort
    );
  }

  Socket? _socket;
  final String _remoteAddress;
  final int _remotePort;

  //Stores the incoming bytes of the TCP connection temporarily
  final List<int> buffer = [];
  //Byte length for json object
  int responseLength = 0;
  //Byte length for subsequent data of the json object
  int payloadLength = 0;

  //Temp filename counter
  int _fileCounter = 0;

  //Construct a stream which emits events on intact requests
  final StreamController<List<int>> _responseRawStreamController = StreamController();
  final StreamController<File> _payloadRawStreamController = StreamController();

  //Construct a payload stream which forward the incoming byte into temp file
  StreamController<List<int>> _payloadPullStreamController = StreamController()..close();

  //Provide a response stream for blocs to listen on
  final StreamController<TCPResponse> _responseStreamController = StreamController();
  Stream<TCPResponse>? _responseStreamBroadcast;
  Stream<TCPResponse> get responseStream => _responseStreamController.stream;
  Stream<TCPResponse> get responseStreamBroadcast {
    _responseStreamBroadcast ??= _responseStreamController.stream.asBroadcastStream();
    return _responseStreamBroadcast!;
  }

  //Provide a request stream for widgets to push to
  final StreamController<TCPRequest> _requestStreamController = StreamController();

  void pushRequest(TCPRequest request) {
    if(request.type == TCPRequestType.sendMessage) {
      request as SendMessageRequest;
      if(request.message.type == MessageType.file) {
        Future(() async {
          //Duplicate current socket
          Socket socket = await Socket.connect(_remoteAddress, _remotePort);
          TCPRepository duplicatedRepository = TCPRepository._internal(
            socket: socket, 
            remoteAddress: _remoteAddress, 
            remotePort: _remotePort
          );
          duplicatedRepository._requestStreamController.add(request);
          await for(var response in duplicatedRepository.responseStreamBroadcast) {
            if(response.type == TCPResponseType.sendMessage) {
              _responseStreamController.add(response);
              break;
            }
          }
          duplicatedRepository.dispose();
        });
      }
      else {
        _requestStreamController.add(request);
      }
    }
    else {
      _requestStreamController.add(request);
    }
  }

  //Listen to the incoming stream and emits event whenever there is a intact request
  void _pullResponse(Uint8List fetchedData) {
    //Put incoming data into buffer
    buffer.addAll(fetchedData);
    //Consume buffer until it's not enough for first 8 byte of a message
    while(true) {
      if(responseLength == 0 && payloadLength == 0 && _payloadPullStreamController.isClosed) {
        //New request
        if(buffer.length >= 12) {
          //Buffered data has more than 8 bytes, enough to read request length and body length
          responseLength = Uint8List.fromList(buffer.sublist(0, 4)).buffer.asInt32List()[0];
          payloadLength = Uint8List.fromList(buffer.sublist(4, 12)).buffer.asInt64List()[0];
          //Clear the length indicator bytes
          buffer.removeRange(0, 12);
          //Create a pull stream for payload file
          _payloadPullStreamController = StreamController();
          //Create a future that listens to the status of the payload transmission
          () {
            var payloadPullStream = _payloadPullStreamController.stream;
            Future(() async {
              var documentDirectory = await getApplicationDocumentsDirectory();
              //Create temp file to read payload (might be huge)
              Directory('${documentDirectory.path}/LChatClient').createSync();
              Directory('${documentDirectory.path}/LChatClient/.tmp').createSync();
              var tempFile = File('${documentDirectory.path}/LChatClient/.tmp/${DateTime.now().microsecondsSinceEpoch}$_fileCounter')..createSync();
              _fileCounter += 1;
              _fileCounter %= 10;
              await for(var data in payloadPullStream) {
                await tempFile.writeAsBytes(data, mode: FileMode.append);
              }
              _payloadRawStreamController.add(tempFile);
            });
          }();
        }
        else {
          //Buffered data is not long enough
          //Do nothing
          break;
        }
      }
      else {
        //Currently awaiting full transmission
        if(responseLength > 0) {
          //Currently processing on a request
          if(buffer.length >= responseLength) {
            //Got intact request json
            //Emit request buffer through stream
            _responseRawStreamController.add(buffer.sublist(0, responseLength));
            //Remove proccessed buffer
            buffer.removeRange(0, responseLength);
            //Clear awaiting request length
            responseLength = 0;
          }
          else {
            //Got part of request json
            //do nothing
            break;
          }
        }
        else {
          //Currently processing on a payload
          if(buffer.length >= payloadLength) {
            //Last few bytes to emit
            //Send the last few bytes to stream
            _payloadPullStreamController.add(buffer.sublist(0, payloadLength));
            //Clear buffer
            buffer.removeRange(0, payloadLength);
            //Set payload length to zero
            payloadLength = 0;
            //Close the payload transmission stream
            _payloadPullStreamController.close();
          }
          else {
            //Part of payload
            //Transmit all to stream
            _payloadPullStreamController.add([...buffer]);
            //Reduce payload bytes left
            payloadLength -= buffer.length;
            //Clear buffer
            buffer.clear();
            //Exit and wait for another submit
            break;
          }
        }
      }
    }
  }

  Future<void> _pushResponse({
    required List<int> responseBytes,
    required File tempFile
  }) async {
    if(_responseStreamController.isClosed) {
      await tempFile.delete();
      return;
    }
    var responseJSON = String.fromCharCodes(responseBytes);
    var responseObject = jsonDecode(responseJSON);
    TCPResponseType responseType = TCPResponseType.fromValue(responseObject['response'] as String);
    switch(responseType) {
      case TCPResponseType.token: {
        await tempFile.delete();
        _responseStreamController.add(SetTokenReponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.checkState: {
        await tempFile.delete();
        _responseStreamController.add(CheckStateResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.register: {
        await tempFile.delete();
        _responseStreamController.add(RegisterResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.login: {
        await tempFile.delete();
        _responseStreamController.add(LoginResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.logout: {
        await tempFile.delete();
        _responseStreamController.add(LogoutResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.profile: {
        await tempFile.delete();
        _responseStreamController.add(GetProfileResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.modifyPassword: {
        await tempFile.delete();
        _responseStreamController.add(ModifyPasswordResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.modifyProfile: {
        await tempFile.delete();
        _responseStreamController.add(ModifyProfileResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.sendMessage: {
        await tempFile.delete();
        _responseStreamController.add(SendMessageResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.forwardMessage: {
        await tempFile.delete();
        _responseStreamController.add(ForwardMessageResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.fetchMessage: {
        await tempFile.delete();
        _responseStreamController.add(FetchMessageResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.findFile: {
        await tempFile.delete();
        _responseStreamController.add(FindFileResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.fetchFile: {
        _responseStreamController.add(FetchFileResponse(
          jsonObject: responseObject,
          payload: LocalFile(
            file: tempFile,
            filemd5: md5.convert(await tempFile.readAsBytes()).toString()
          )
        ));
        break;
      }
      case TCPResponseType.searchUser: {
        await tempFile.delete();
        _responseStreamController.add(SearchUserResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.addContact: {
        await tempFile.delete();
        _responseStreamController.add(AddContactResponse(jsonObject: responseObject));
        break;
      }
      case TCPResponseType.fetchContact: {
        await tempFile.delete();
        _responseStreamController.add(FetchContactResponse(jsonObject: responseObject));
        break;
      }
      default: {
        await tempFile.delete();
        break;
      }
    }
  }

  Future<bool> checkFileExistence({
    required LocalFile file
  }) async {
    //Duplicate current socket
    Socket socket = await Socket.connect(_remoteAddress, _remotePort);
    TCPRepository duplicatedRepository = TCPRepository._internal(
      socket: socket, 
      remoteAddress: _remoteAddress, 
      remotePort: _remotePort
    );
    var pref = await SharedPreferences.getInstance();
    var request = FindFileRequest(file: file, token: pref.getInt('token')!);
    duplicatedRepository.pushRequest(request);
    var hasFile = false;
    await for(var response in duplicatedRepository.responseStream) {
      if(response.type == TCPResponseType.findFile) {
        hasFile = response.status == TCPResponseStatus.ok;
        break;
      }
    }
    duplicatedRepository.dispose();
    return hasFile;
  }

  void dispose() async {
    await _socket?.flush();
    await _socket?.close();
  }
}