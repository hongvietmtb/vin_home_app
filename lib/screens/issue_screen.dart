import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vin_home_app/models/account_public.dart';
import 'package:vin_home_app/models/data.dart';
import 'package:vin_home_app/models/issue.dart';
import 'package:vin_home_app/blocs/issue_bloc.dart';

const _BASE_URL = 'http://report.bekhoe.vn';
const _DEFAULT_LIMIT = 5;
const _DEFAULT_OFFSET = 0;
const _DEFAULT_IMG_SHOW = 3;
const Map<int, String> _STATUS = {0:'Đang chờ',1:'Đang xử lý',2:'Đã xong',3:'Huỷ bỏ',4:'Không duyệt'};

class IssueScreen extends StatefulWidget {
  const IssueScreen({Key? key}) : super(key: key);

  @override
  _IssueScreenState createState() => _IssueScreenState();
}

class _IssueScreenState extends State<IssueScreen> {
  ScrollController scrollController = ScrollController();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final issueBloc = IssueBloc();
  var issues = <Data>[];
  var isLoading = false;
  var isFinish = false;
  var isRefresh = false;
  var nextOffset = _DEFAULT_OFFSET;

  @override
  void initState() {
    issueBloc.getIssue(_DEFAULT_LIMIT, nextOffset);
    scrollController.addListener(() {
      _scrollListener();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.removeListener(() {
      _scrollListener();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sự cố"),
        backgroundColor: Colors.teal,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: StreamBuilder<Issue>(
          stream: issueBloc.stream,
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              var countBefore = issues.length;
              var countAfter = 0;
              if (snapshot.data != null && snapshot.data!.data != null) {
                issues.addAll(snapshot.data!.data ?? <Data>[]);
                countAfter = issues.length;
              }

              if (countAfter > countBefore) {
                nextOffset = nextOffset + _DEFAULT_LIMIT;
              } else if(!isRefresh) {
                isFinish = true;
              }
              isLoading = false;
              isRefresh = false;
              return buildContent();
            }
            if (snapshot.hasError) {
              var error = snapshot.error;
              if (error == null) {
                error = "";
              }
              isLoading = false;
              isRefresh = false;
              return buildErrorMsg(error.toString());
            }

            //loading screen
            isLoading = false;
            isRefresh = false;
            return Container(
              color: Colors.grey[250],
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.teal,
                ),
              ),
            );
          }),
    );
  }

  Widget buildContent() {
    var account = AccountPublic();
    var issue = Data();
    var photos = <Object>[];
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(5),
      itemCount: issues.length,
      itemBuilder: (BuildContext ctx, int index) {
        issue = issues[index];
        account = issue.accountPublic ?? AccountPublic();
        photos = issue.photos ?? <List>[];
        return Card(
          margin: EdgeInsets.all(10),
          color: Colors.white,
          child: Column(
            children: [
              buildHeader(account, issue),
              Divider(
                indent: 15,
                endIndent: 15,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 5,
                  bottom: 5,
                ),
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  issue.title ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 5,
                  bottom: 5,
                ),
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  issue.content ?? "",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              buildGridView(issue, photos),
            ],
          ),
        );
      },
    );
  }

  Widget buildErrorMsg(String error) {
    return Container(
      child: Text(error),
    );
  }

  Widget buildHeader(AccountPublic account, Data data) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.yellow,
              ),
              child: Image.network(
                _BASE_URL + (account.avatar ?? ""),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.name ?? '',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                data.createdAt ?? '',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
          Expanded(
            child: Container(
                alignment: AlignmentDirectional.topEnd,
                child: Text(
                  _STATUS[data.status]??"",
                  style: TextStyle(
                    fontSize: 18,
                    color: data.status == 4 ? Colors.red : data.status == 2 ? Colors.green : null,
                  ),
                )),
          )
        ],
      ),
    );
  }

  void _scrollListener() {
    if (!isLoading && !isFinish) {
      if (scrollController.position.extentAfter < 200) {
        isLoading = true;
        issueBloc.getIssue(_DEFAULT_LIMIT, nextOffset);
      }
    }
  }

  Widget buildGridViewItem(int photoCount, int index, Object photo) {
    if (photoCount > _DEFAULT_IMG_SHOW && index == _DEFAULT_IMG_SHOW - 1) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            _BASE_URL + photo.toString(),
            fit: BoxFit.contain,
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black54.withOpacity(0.6),
            alignment: Alignment.center,
            child: Text(
              "+" + (photoCount - _DEFAULT_IMG_SHOW + 1).toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
        ],
      );
    }
    return Image.network(
      _BASE_URL + photo.toString(),
      fit: BoxFit.contain,
    );
  }

  Widget buildGridView(Data issue, List<Object> photos) {
    if (photos.length == 0) {
      return Container();
    }
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
        bottom: 15,
      ),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      primary: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: photos.length <= _DEFAULT_IMG_SHOW
            ? photos.length
            : _DEFAULT_IMG_SHOW,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        //mainAxisExtent: 200,
      ),
      itemCount: photos.length <= _DEFAULT_IMG_SHOW
          ? photos.length
          : _DEFAULT_IMG_SHOW,
      itemBuilder: (BuildContext context, index) {
        return Container(
          color: Colors.grey[400],
          child: Container(
            child: buildGridViewItem(photos.length, index, photos[index]),
          ),
        );
      },
    );
  }
  Future<void> refreshData() async{
    if(!isLoading) {
      issues = <Data>[];
      nextOffset = 0;
      isRefresh = true;
      isFinish = false;
      isLoading = true;
      issueBloc.getIssue(_DEFAULT_LIMIT, nextOffset);
      // setState(() {
      //
      // });
    }
  }
}
