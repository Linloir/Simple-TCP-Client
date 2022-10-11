/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 09:42:05
 * @LastEditTime : 2022-10-11 22:55:28
 * @Description  : TCP repository
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_request.dart';
import 'package:tcp_client/repositories/tcp_repository/models/tcp_response.dart';

class TCPRepository {
  TCPRepository({
    required Socket socket,
    required String remoteAddress,
    required int remotePort
  }): _socket = socket, _remoteAddress = remoteAddress, _remotePort = remotePort {
    _socket.listen(_pullResponse);
    //This future never ends, would that be bothersome?
    Future(() async {
      await for(var request in _requestStreamController.stream) {
        await _socket.addStream(request.stream);
      }
    });
    Future(() async {
      await for(var response in _responseRawStreamController.stream) {
        var payloadFile = await _payloadRawStreamController.stream.single;
        await _pushResponse(responseBytes: response, tempFile: payloadFile);
      }
    });
  }

  final Socket _socket;
  final String _remoteAddress;
  final int _remotePort;

  //Stores the incoming bytes of the TCP connection temporarily
  final List<int> buffer = [];
  //Byte length for json object
  int responseLength = 0;
  //Byte length for subsequent data of the json object
  int payloadLength = 0;

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

  Future<void> pushRequest(TCPRequest request) async {
    _requestStreamController.add(request);
  }

  //Listen to the incoming stream and emits event whenever there is a intact request
  void _pullResponse(Uint8List fetchedData) {
    //Put incoming data into buffer
    buffer.addAll(fetchedData);
    //Consume buffer until it's not enough for first 8 byte of a message
    while(true) {
      if(responseLength == 0 && payloadLength == 0 && _payloadPullStreamController.isClosed) {
        //New request
        if(buffer.length >= 8) {
          //Buffered data has more than 8 bytes, enough to read request length and body length
          responseLength = Uint8List.fromList(buffer.sublist(0, 4)).buffer.asInt32List()[0];
          payloadLength = Uint8List.fromList(buffer.sublist(4, 8)).buffer.asInt32List()[0];
          //Clear the length indicator bytes
          buffer.removeRange(0, 8);
          //Create temp file to read payload (might be huge)
          var tempFile = File('${Directory.current.path}/.tmp/${DateTime.now().microsecondsSinceEpoch}')..createSync();
          //Create a pull stream for payload file
          _payloadPullStreamController = StreamController();
          //Create a future that listens to the status of the payload transmission
          Future(() async {
            await for(var data in _payloadPullStreamController.stream) {
              await tempFile.writeAsBytes(data, mode: FileMode.append, flush: true);
            }
            _payloadRawStreamController.add(tempFile);
          });
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
            _responseRawStreamController.close();
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
            _payloadPullStreamController.add(Uint8List.fromList(buffer.sublist(0, payloadLength)));
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
            _payloadPullStreamController.add(Uint8List.fromList(buffer));
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
            filemd5: md5.convert(await tempFile.readAsBytes()).toString(),
            ext: ""
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
    TCPRepository duplicatedRepository = TCPRepository(
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

  void dispose() {
    _responseRawStreamController.close();
    _payloadPullStreamController.close();
    _payloadRawStreamController.close();
    _responseStreamController.close();
    _requestStreamController.close();
    _socket.close();
  }
}