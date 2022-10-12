/*
 * @Author       : Linloir
 * @Date         : 2022-10-12 09:53:48
 * @LastEditTime : 2022-10-12 14:53:19
 * @Description  : Splash page before main TCP connection and database is ready
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tcp_client/initialization/cubit/initialization_cubit.dart';
import 'package:tcp_client/initialization/cubit/initialization_state.dart';

class InitializePage extends StatelessWidget {
  const InitializePage({super.key});

  static Route<void> route({
    required String serverAddress,
    required int serverPort,
    required String databasePath
  }) {
    return MaterialPageRoute<void>(builder: (context) => const InitializePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
              child: const LoadingIndicator(
                indicatorType: Indicator.ballScale,
                colors: [Colors.grey],
              ),
            ),
            const SizedBox(height: 12,),
            BlocBuilder<InitializationCubit, InitializationState>(
              builder:(context, state) {
                if(state.databaseStatus == InitializationStatus.done) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                      ),
                      SizedBox(width: 6,),
                      Text('Database initialized.')
                    ],
                  );
                }
                else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 6,),
                      Text('Database initializing...')
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 8,),
            BlocBuilder<InitializationCubit, InitializationState>(
              builder:(context, state) {
                if(state.mainSocketStatus == InitializationStatus.done) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                      ),
                      SizedBox(width: 6,),
                      Text('TCP connection initialized.')
                    ],
                  );
                }
                else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 6,),
                      Text('TCP connection initializing...')
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 8,),
            BlocBuilder<InitializationCubit, InitializationState>(
              builder:(context, state) {
                if(state.tokenStatus == InitializationStatus.done) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                      ),
                      SizedBox(width: 6,),
                      Text('Device status verified.')
                    ],
                  );
                }
                else {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 6,),
                      Text('Verifying device login status...')
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
