/*
 * @Author       : Linloir
 * @Date         : 2022-10-11 10:55:36
 * @LastEditTime : 2022-10-11 22:54:59
 * @Description  : Local File Model
 */

import 'dart:io';

import 'package:equatable/equatable.dart';

class LocalFile extends Equatable {
  final File file;
  final String filemd5;
  final String ext;

  const LocalFile({required this.file, required this.filemd5, required this.ext});

  @override
  List<Object> get props => [filemd5];
}
