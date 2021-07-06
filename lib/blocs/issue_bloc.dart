import 'dart:async';

import 'package:vin_home_app/models/issue.dart';
import 'package:vin_home_app/services/api_service.dart';
import 'package:vin_home_app/services/issue_service.dart';

class IssueBloc {
  final _streamController = StreamController<Issue>();
  Stream<Issue> get stream => _streamController.stream;

  var issue = Issue();

  IssueBloc();

  void dispose() {
    _streamController.close();
  }

  void getIssue(int limit, int offset) {
    apiService.getIssue(
        limit: limit,
        offset: offset,
        onSuccess: (data) {
          this.issue = data;
          _streamController.sink.add(this.issue);
        },
        onFailure: (error) {
          _streamController.addError(error);
        });
  }
}
