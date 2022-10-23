/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 10:56:02
 * @LastEditTime : 2022-10-23 17:10:13
 * @Description  : Local Service Repository
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_client/repositories/common_models/message.dart';
import 'package:tcp_client/repositories/common_models/userinfo.dart';
import 'package:tcp_client/repositories/local_service_repository/models/local_file.dart';
import 'package:sqflite/sqflite.dart';

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
      await txn.execute(
      '''
        create table msgimgs (
          msgmd5      text primary key,
          imgmd5      text not null
        );
      '''
      );
      await txn.execute(
      '''
        create table imgs (
          imgmd5      text primary key,
          dir         text not null
        );
      '''
      );
      await txn.execute(
        '''
          create table readhistory (
            userid    int not null,
            targetid  int not null,
            timestamp  int not null,
            primary key (userid, targetid)
          )
        '''
      );
    });
  }

  static Future<void> _updateDatabaseToVer2(Database db) async {
    await db.transaction((txn) async {
      db.execute(
        '''
          create table readhistory (
            userid      int not null,
            targetid    int not null,
            timestamp    int not null,
            primary key (userid, targetid)
          )
        '''
      );
    });
  }

  static FutureOr<void> _onDatabaseUpgrade(Database db, int curVer, int newVer) async {
    if(curVer == 1 && newVer == 2) {
      await _updateDatabaseToVer2(db);
    }
  }

  static Future<LocalServiceRepository> create({
    UserInfo? currentUser,
    required String databaseFilePath
  }) async {
    var database = await openDatabase(
      databaseFilePath,
      version: 2,
      onCreate: _onDatabaseCreate,
      onUpgrade: _onDatabaseUpgrade,
    );
    return LocalServiceRepository._internal(database: database);
  }

  //Calls on the system to open the file
  Future<File?> pickFile(FileType fileType) async {
    var filePickResult = await FilePicker.platform.pickFiles(
      type: fileType,
      allowMultiple: false,
    );
    if (filePickResult == null) return null;
    var file = File(filePickResult.files.single.path!);
    return file;
  }

  Future<void> storeMessages(List<Message> messages) async {
    await _database.transaction((txn) async {
      for(var message in messages) {
        if(message.type == MessageType.image) {
          //store image first
          storeImage(
            image: base64.decode(message.contentDecoded), 
            msgmd5: message.contentmd5
          );
          await txn.insert(
            'msgs',
            message.jsonObject..['content'] = "",
            conflictAlgorithm: ConflictAlgorithm.replace
          );
        }
        else {
          await txn.insert(
            'msgs',
            message.jsonObject,
            conflictAlgorithm: ConflictAlgorithm.replace
          );
        }
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
      where: '(userid = ? or targetid = ?) and not contenttype = ?',
      whereArgs: [
        currentUserID, currentUserID, MessageType.image.literal
      ],
      orderBy: 'timestamp desc',
      limit: 100
    );
    List<Message> alikeMessages = [];
    for(var rawMessage in rawMessages) {
      var message = Message.fromJSONObject(jsonObject: rawMessage);
      if(message.contentDecoded.toLowerCase().contains(pattern.toLowerCase())) {
        //Since history page does not show message
        //There is no need to fetch message here
        // if(message.type == MessageType.image) {
        //   var image = await fetchImage(msgmd5: message.contentmd5);
        //   if(image != null) {
        //     alikeMessages.add(message.copyWith(
        //       content: base64.encode(image),
        //     ));
        //     continue;
        //   }
        //   else {
        //     //TODO: do something
        //   }
        // }
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
        //Since message page does not show message
        //There is no need to fetch message here
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
    List<Message> messages = [];
    for(var result in queryResult) {
      var message = Message.fromJSONObject(jsonObject: result);
      if(message.type == MessageType.image) {
        var image = await fetchImage(msgmd5: message.contentmd5);
        if(image != null) {
          message = message.copyWith(content: base64.encode(image));
        }
      }
      messages.add(message);
    }
    return messages;
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
        // var duplicate = 0;
        //Rename target file
        await Directory('$documentPath/LChatClient/files').create();
        await Directory('$documentPath/LChatClient/files/$userID').create();
        var targetFilePath = '$documentPath/LChatClient/files/$userID/$fileBaseName$fileExt';
        var targetFile = File(targetFilePath);
        // while(await targetFile.exists()) {
        //   duplicate += 1;
        //   targetFilePath = '$documentPath/LChatClient/files/$userID/$fileBaseName($duplicate)$fileExt';
        //   targetFile = File(targetFilePath);
        // }
        if(!await targetFile.exists()) {
          targetFile = await file.copy(targetFilePath);
        }
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
    await Directory('$documentPath/LChatClient/files').create();
    await Directory('$documentPath/LChatClient/files/.lib').create();
    var permanentFilePath = '$documentPath/LChatClient/files/.lib/${tempFile.filemd5}';
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

  Future<void> storeImage({required List<int> image, required String msgmd5}) async {
    var md5Output = AccumulatorSink<Digest>();
    ByteConversionSink md5Input = md5.startChunkedConversion(md5Output);
    md5Input.add(image);
    md5Input.close();
    var imagemd5 = md5Output.events.single.toString();
    //Write to image library
    var documentPath = (await getApplicationDocumentsDirectory()).path;
    await Directory('$documentPath/LChatClient/imgs').create();
    var permanentFilePath = '$documentPath/LChatClient/imgs/$imagemd5';
    var imageFile = await File(permanentFilePath).create();
    imageFile.writeAsBytes(image);
    await _database.transaction((txn) async {
      txn.insert(
        'msgimgs',
        {
          'msgmd5': msgmd5,
          'imgmd5': imagemd5
        },
        conflictAlgorithm: ConflictAlgorithm.replace
      );
      txn.insert(
        'imgs',
        {
          'imgmd5': imagemd5,
          'dir': permanentFilePath
        },
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    });
  }

  Future<List<int>?> fetchImage({required String msgmd5}) async {
    var imageQueryResult = await _database.query(
      'msgimgs natural join imgs',
      where: 'msgimgs.msgmd5 = ?',
      whereArgs: [
        msgmd5
      ],
      columns: [
        'imgs.dir as dir'
      ]
    );
    if(imageQueryResult.isEmpty) {
      return null;
    }
    var path = imageQueryResult[0]['dir'] as String;
    var image = File(path);
    if(!await image.exists()) {
      return null;
    }
    var imageContent = await image.readAsBytes();
    return imageContent;
  }

  Future<void> setReadHistory({
    required int userid,
    required int targetid,
    required int timestamp
  }) async {
    await _database.transaction((txn) async {
      var result = await txn.query(
        'readhistory',
        where: 'userid = ? and targetid = ?',
        whereArgs: [
          userid,
          targetid
        ]
      );
      if(result.isEmpty) {
        await txn.insert(
          'readhistory',
          {
            'userid': userid,
            'targetid': targetid,
            'timestamp': timestamp
          }
        );
        return;
      }
      if(result[0]['timestamp'] as int > timestamp) {
        return;
      }
      await txn.update(
        'readhistory',
        {
          'timestamp': timestamp
        },
        where: 'userid = ? and targetid = ?',
        whereArgs: [
          userid,
          targetid
        ]
      );
    });
  }

  Future<int> fetchReadHistory({
    required int userid,
    required int targetid
  }) async {
    return await _database.transaction<int>((txn) async {
      var result = await txn.query(
        'readhistory',
        where: 'userid = ? and targetid = ?',
        whereArgs: [
          userid,
          targetid,
        ],
      );
      if(result.isEmpty) {
        txn.insert(
          'readhistory',
          {
            'userid': userid,
            'targetid': targetid,
            'timestamp': 0
          },
        );
        return 0;
      }
      return result[0]['timestamp'] as int;
    });
  }

  Future<int> getUnreadCount({
    required int userid,
    required int targetid
  }) async {
    return await _database.transaction<int>((txn) async {
      var result = await txn.query(
        'msgs left outer join readhistory on msgs.userid = readhistory.targetid and msgs.targetid = readhistory.userid',
        columns: [
          'msgs.md5encoded'
        ],
        where: 'msgs.userid = ? and msgs.targetid = ? and msgs.timestamp > readhistory.timestamp',
        whereArgs: [
          targetid,
          userid
        ]
      );
      return result.length;
    });
  }
}
