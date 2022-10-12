/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 10:55:36
 * @LastEditTime : 2022-10-12 09:19:50
 * @Description  : Local File Model
 */

import 'dart:io';

import 'package:equatable/equatable.dart';

class LocalFile extends Equatable {
  final File file;
  final String filemd5;

  const LocalFile({required this.file, required this.filemd5});

  @override
  List<Object> get props => [filemd5];
}
