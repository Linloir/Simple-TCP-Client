/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 09:57:48
 * @LastEditTime : 2022-10-12 13:59:14
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/repositories/local_service_repository/local_service_repository.dart';
import 'package:tcp_client/repositories/tcp_repository/tcp_repository.dart';

enum InitializationStatus { pending, done }

class InitializationState extends Equatable {
  const InitializationState({
    required this.databaseStatus,
    required this.mainSocketStatus,
    required this.tokenStatus,
    this.localServiceRepository,
    this.tcpRepository
  });

  const InitializationState.init(): this(
    databaseStatus: InitializationStatus.pending, 
    mainSocketStatus: InitializationStatus.pending,
    tokenStatus: InitializationStatus.pending
  );

  final InitializationStatus databaseStatus;
  final InitializationStatus mainSocketStatus;
  final InitializationStatus tokenStatus;
  final LocalServiceRepository? localServiceRepository;
  final TCPRepository? tcpRepository;

  InitializationState copyWith({
    InitializationStatus? databaseStatus,
    InitializationStatus? mainSocketStatus,
    InitializationStatus? tokenStatus,
    LocalServiceRepository? localServiceRepository,
    TCPRepository? tcpRepository
  }) {
    return InitializationState(
      databaseStatus: databaseStatus ?? this.databaseStatus,
      mainSocketStatus: mainSocketStatus ?? this.mainSocketStatus,
      tokenStatus: tokenStatus ?? this.tokenStatus,
      localServiceRepository: localServiceRepository ?? this.localServiceRepository,
      tcpRepository: tcpRepository ?? this.tcpRepository
    );
  }

  bool get isDone => databaseStatus == InitializationStatus.done &&
                     mainSocketStatus == InitializationStatus.done &&
                     tokenStatus == InitializationStatus.done;

  @override
  List<Object> get props => [databaseStatus, mainSocketStatus, tokenStatus];
}
