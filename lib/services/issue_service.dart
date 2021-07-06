import 'package:vin_home_app/models/issue.dart';
import 'package:vin_home_app/services/api_service.dart';

extension IssueService on ApiService {
  Future<void> getIssue(
      {required int limit,
      required int offset,
      required Function(Issue) onSuccess,
      required Function(String) onFailure}) async {
    request(
        path: "/api/issues?limit=" + limit.toString() + "&offset=" + offset.toString(),
        method: Method.get,
        onSuccess: (json) {
          final issue = Issue.fromJson(json);
          onSuccess(issue);
        },
        onFailure: onFailure);
  }
}
