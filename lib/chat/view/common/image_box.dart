/*
 * @Author       : Linloir
 * @Date         : 2022-10-14 17:04:20
 * @LastEditTime : 2022-10-23 13:00:51
 * @Description  : 
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tcp_client/chat/cubit/chat_cubit.dart';
import 'package:tcp_client/chat/model/chat_history.dart';

class ImageBox extends StatelessWidget {
  const ImageBox({
    required this.history,
    super.key
  });

  final ChatHistory history;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 200, maxHeight: 150),
              child: Hero(
                tag: history.message.contentmd5,
                child: history.preCachedImage ?? Image.memory(base64Decode(history.message.contentDecoded)),
              ),
            ),
            Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.1),
                  onTap: (){
                    context.read<ChatCubit>().unFocus();
                    var image = history.preCachedImage?.image ?? Image.memory(base64.decode(history.message.contentDecoded)).image;
                    Navigator.of(context).push(MaterialPageRoute(
                      builder:(context) {
                        return Scaffold(
                          body: Stack(
                            children: [
                              Positioned.fill(
                                child: PhotoView(
                                  heroAttributes: PhotoViewHeroAttributes(
                                    tag: history.message.contentmd5
                                  ),
                                  imageProvider: image,
                                  minScale: PhotoViewComputedScale.contained,
                                )
                              ),
                              Positioned.fill(
                                child: SafeArea(
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.close_rounded,
                                        shadows: [
                                          Shadow(blurRadius: 8.0, color: Colors.white.withOpacity(0.5))
                                        ],
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ));
                  },
                )
              ),
          ]
        ),
      ),
    );
  }
}
