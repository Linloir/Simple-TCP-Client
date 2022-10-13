/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 17:30:26
 * @LastEditTime : 2022-10-13 21:28:46
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/common_models/message.dart';

class HistorySearchResult extends Equatable {
  final int contact;
  final Message message;

  const HistorySearchResult({
    required this.contact,
    required this.message
  });

  @override
  List<Object> get props => [contact, message.contentmd5];
}
