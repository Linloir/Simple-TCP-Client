/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 17:06:52
 * @LastEditTime : 2022-10-13 21:35:11
 * @Description  : 
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcp_client/search/cubit/search_cubit.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        context.read<SearchCubit>().onKeyChanged(value);
      },
    );
  }
}
