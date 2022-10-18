/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 10:56:02
 * @LastEditTime : 2022-10-18 11:27:15
 * @Description  : Local Service Repository
 */

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';
//Windows platform
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
//Android platform
// import 'package:sqflite/sqflite.dart';

class LocalServiceRepository {
  late final Database _database;

  LocalServiceRepository._internal({
    required Database database
  }): _database = database;

  static FutureOr<void> _onDatabaseCreate(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute(
      '''
        create table users (
          userid    integer primary key,
          username  text not null,
          avatar    text
        );
      '''
      );
      await txn.execute(
      '''
        create table msgs (
          userid      integer not null,
          targetid    integer not null,
          contenttype text not null,
          content     text not null,
          timestamp   int not null,
          md5encoded  text primary key,
          filemd5     text
        );
      '''
      );
      await txn.execute(
      '''
        create table files (
          filemd5     text primary key,
          dir         text not null
        );
      '''
      );
    });
    // await db.execute(
    //   '''
    //     create table msgs (
    //       userid      integer not null,
    //       targetid    integer not null,
    //       contenttype text not null,
    //       content     text not null,
    //       timestamp   int not null,
    //       md5encoded  text primary key,
    //       filemd5     text
    //     );
    //     create table users (
    //       userid    integer primary key,
    //       username  text not null,
    //       avatar    text
    //     );
    //     create table files (
    //       filemd5     text primary key,
    //       dir         text not null
    //     );
    //   '''
    // );
  }

  static Future<LocalServiceRepository> create({
    UserInfo? currentUser,
    required String databaseFilePath
  }) async {
    //Windows platform
    var database = await databaseFactoryFfi.openDatabase(
      databaseFilePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onDatabaseCreate
      )
    );
    //Android platform
    // var database = await openDatabase(
    //   databaseFilePath,
    //   version: 1,
    //   onCreate: _onDatabaseCreate
    // );
    return LocalServiceRepository._internal(database: database);
  }

  //Calls on the system to open the file
  Future<LocalFile?> pickFile(FileType fileType) async {
    var filePickResult = await FilePicker.platform.pickFiles(
      type: fileType,
      allowMultiple: false,
    );
    if (filePickResult == null) return null;
    var file = File(filePickResult.files.single.path!);
    return LocalFile(
      file: file, 
      filemd5: md5.convert(await file.readAsBytes()).toString()
    );
  }

  Future<void> storeMessages(List<Message> messages) async {
    await _database.transaction((txn) async {
      for(var message in messages) {
        await txn.insert(
          'msgs',
          message.jsonObject,
          conflictAlgorithm: ConflictAlgorithm.replace
        );
      }
    });
  }

  Future<List<Message>> findMessages({required String pattern}) async {
    if(pattern.isEmpty) {
      return [];
    }
    // Obtain shared preferences.
    final pref = await SharedPreferences.getInstance();
    // Get user info from preferences
    var currentUserID = pref.getInt('userid');
    var rawMessages = await _database.query(
      'msgs',
      where: '(userid = ? or targetid = ?)',
      whereArgs: [
        currentUserID, currentUserID
      ],
      orderBy: 'timestamp desc',
      limit: 100
    );
    List<Message> alikeMessages = [];
    for(var rawMessage in rawMessages) {
      var message = Message.fromJSONObject(jsonObject: rawMessage);
      if(message.contentDecoded.contains(pattern)) {
        alikeMessages.add(message);
      }
    }
    return alikeMessages;
  }

  //Find the most recent message of given users
  Future<List<List<Message>>> fetchMessageList({required List<int> users}) async {
    var pref = await SharedPreferences.getInstance();
    var currentUserID = pref.getInt('userid');
    var messages = <List<Message>>[];
    for(var user in users) {
      var queryResult = await _database.query(
        'msgs',
        where: '(userid = ? and targetid = ?) and (userid = ? and targetid = ?)',
        whereArgs: [
          currentUserID, user, user, currentUserID
        ],
        orderBy: 'timestamp desc',
        limit: 1
      );
      if(queryResult.isEmpty) {
        messages.add([]);
      }
      else {
        messages.add([Message.fromJSONObject(jsonObject: queryResult[0])]);
      }
    }
    return messages;
  }

  //Fetch chat history with another user, provided the user ID
  Future<List<Message>> fetchMessageHistory({required int userID, required int position, int num = 20}) async {
    //the histories with userID
    var pref = await SharedPreferences.getInstance();
    var currentUserID = pref.getInt('userid');
    if(currentUserID == null) {
      //TODO: do something
      return [];
    }
    var queryResult = await _database.query(
      'msgs',
      where: '(userid = ? and targetid = ?) or (userid = ? and targetid = ?)',
      whereArgs: [
        currentUserID, userID, userID, currentUserID
      ],
      orderBy: 'timestamp desc',
      limit: num,
      offset: position
    );
    return queryResult.map((e) => Message.fromJSONObject(jsonObject: e)).toList();
  }

  Future<File?> findFile({required String filemd5, required String fileName}) async {
    var directory = await _database.query(
      'files',
      where: 'filemd5 = ?',
      whereArgs: [
        filemd5
      ]
    );
    if(directory.isEmpty) {
      return null;
    }
    else {
      var filePath = directory[0]['dir'] as String;
      //Try if the file exists
      var file = File(filePath);
      if(await file.exists()) {
        //Copy to desired file path
        var pref = await SharedPreferences.getInstance();
        var userID = pref.getInt('userid');
        var documentPath = (await getApplicationDocumentsDirectory()).path;
        var fileBaseName = fileName.substring(0, fileName.lastIndexOf('.'));
        var fileExt = fileName.substring(fileName.lastIndexOf('.'));
        var duplicate = 0;
        //Rename target file
        await Directory('$documentPath/files').create();
        await Directory('$documentPath/files/$userID').create();
        var targetFilePath = '$documentPath/files/$userID/$fileBaseName$fileExt';
        var targetFile = File(targetFilePath);
        while(await targetFile.exists()) {
          duplicate += 1;
          targetFilePath = '$documentPath/files/$userID/$fileBaseName($duplicate)$fileExt';
          targetFile = File(targetFilePath);
        }
        targetFile = await file.copy(targetFilePath);
        return targetFile;
      }
      else {
        //Delete all linked files
        await _database.delete(
          'files',
          where: 'filemd5 = ?',
          whereArgs: [
            filemd5
          ]
        );
        //TODO: maybe throw some error here?
        return null;
      }
    }
  }
  
  Future<void> storeFile({
    required LocalFile tempFile
  }) async {
    //Write to file library
    var documentPath = (await getApplicationDocumentsDirectory()).path;
    await Directory('$documentPath/files').create();
    await Directory('$documentPath/files/.lib').create();
    var permanentFilePath = '$documentPath/files/.lib/${tempFile.filemd5}';
    await tempFile.file.copy(permanentFilePath);
    try{
      await _database.insert(
        'files',
        {
          'filemd5': tempFile.filemd5,
          'dir': permanentFilePath
        },
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    } catch (err) {
      //TODO: Log the err
    }
    //Clear temp file
    tempFile.file.delete();
  }

  final StreamController<UserInfo> _userInfoChangeStreamController = StreamController();
  Stream<UserInfo> get userInfoChangedStream => _userInfoChangeStreamController.stream;

  Future<void> storeUserInfo({
    required UserInfo userInfo
  }) async {
    await _database.transaction((txn) async {
      //check if exist
      var queryResult = await txn.query(
        'users',
        where: 'userid = ?',
        whereArgs: [userInfo.userID]
      );
      if(queryResult.isEmpty) {
        txn.insert(
          'users',
          userInfo.jsonObject
        );
      }
      else {
        txn.update(
          'users',
          userInfo.jsonObject,
          where: 'userid = ?',
          whereArgs: [userInfo.userID]
        );
      }
      _userInfoChangeStreamController.add(userInfo);
    });
  }

  Future<UserInfo?> fetchUserInfoViaID({required int userid}) async {
    var targetUser = await _database.query(
      'users',
      where: 'userid = ?',
      whereArgs: [userid]
    );
    if(targetUser.isEmpty) {
      return null;
    }
    else {
      return UserInfo.fromJSONObject(jsonObject: targetUser[0]);
    }
  }

  Future<UserInfo?> fetchUserInfoViaUsername({required String username}) async {
    var result = await _database.query(
      'users',
      where: 'username = ?',
      whereArgs: [
        username
      ]
    );
    if(result.isEmpty) {
      return null;
    }
    else {
      return UserInfo.fromJSONObject(jsonObject: result[0]);
    }
  }

  Future<Message?> fetchMessage({required String msgmd5}) async {
    var result = await _database.query(
      'msgs',
      where: 'md5encoded = ?',
      whereArgs: [
        msgmd5
      ]
    );
    if(result.isNotEmpty) {
      return Message.fromJSONObject(jsonObject: result[0]);
    }
    else {
      return null;
    }
  }
}
