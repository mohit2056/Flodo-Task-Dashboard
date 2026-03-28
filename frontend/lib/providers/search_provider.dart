import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search Query Notifier
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => "";

  void setQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

// Status Filter Notifier
class StatusFilterNotifier extends Notifier<String> {
  @override
  String build() => "All";

  void setFilter(String filter) {
    state = filter;
  }
}

final statusFilterProvider = NotifierProvider<StatusFilterNotifier, String>(() {
  return StatusFilterNotifier();
});