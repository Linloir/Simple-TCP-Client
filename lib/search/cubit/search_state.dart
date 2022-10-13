/*
 * @Author       : Linloir
 * @Date         : 2022-10-13 17:08:56
 * @LastEditTime : 2022-10-13 17:42:33
 * @Description  : 
 */

import 'package:equatable/equatable.dart';
import 'package:tcp_client/search/model/history_result.dart';
import 'package:tcp_client/search/model/user_result.dart';

class SearchState extends Equatable {
  const SearchState({
    required this.historyResults,
    required this.userResults
  });
  const SearchState.empty(): historyResults = const [], userResults = const [];

  final List<HistorySearchResult> historyResults;
  final List<UserSearchResult> userResults;

  SearchState copyWith({
    List<HistorySearchResult>? historyResults,
    List<UserSearchResult>? userResults
  }) {
    return SearchState(
      historyResults: historyResults ?? this.historyResults,
      userResults: userResults ?? this.userResults
    );
  }

  @override
  List<Object> get props => [historyResults, userResults];
}
