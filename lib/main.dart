import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import 'box.dart';

main(List<String> args) {
  runApp(BoxApp(model: BoxInfoModel()));
}

class BoxInfoModel extends Model {
  String totalBox;
  String updateInfo;
  String error;
  List<Box> _boxs;
  bool _sortInAscending = false;

  UnmodifiableListView<Box> get boxs => UnmodifiableListView(_boxs);

  void fetch() async {
    http.Response response;

    try {
      response =
          await http.get('https://box.maoyan.com/promovie/api/box/second.json');
    } catch (e) {}

    if (response != null && response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);

      if (result['success'] as bool) {
        Map<String, dynamic> data = result['data'];

        totalBox = '${data['totalBox']}${data['totalBoxUnit']}';
        updateInfo = data['updateInfo'];
        error = null;

        _boxs = List.of(data['list']).map((item) => Box.fromJson(item)).toList()
          ..sort((boxA, boxB) {
            if (_sortInAscending) {
              return boxA.boxInfo.compareTo(boxB.boxInfo);
            } else {
              return boxB.boxInfo.compareTo(boxA.boxInfo);
            }
          });
      } else {
        error = '加载失败，请稍后再试';
      }
    } else {
      error = '加载失败，请稍后再试';
    }

    notifyListeners();

    Timer(
      Duration(seconds: 3),
      () {
        this.fetch();
      },
    );
  }

  void sort(ascending) {
    _sortInAscending = ascending;

    _boxs.sort((boxA, boxB) {
      if (_sortInAscending) {
        return boxA.boxInfo.compareTo(boxB.boxInfo);
      } else {
        return boxB.boxInfo.compareTo(boxA.boxInfo);
      }
    });

    notifyListeners();
  }
}

class BoxApp extends StatelessWidget {
  final BoxInfoModel model;

  BoxApp({Key key, this.model}) : super(key: key) {
    model.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: MaterialApp(
        title: '今日实时票房',
        home: Scaffold(
          appBar: AppBar(
            title: Text('今日实时票房'),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 32,
                horizontal: 16,
              ),
              child: ScopedModelDescendant<BoxInfoModel>(
                  builder: (context, child, model) {
                model.addListener(() {
                  ScaffoldState scaffold = Scaffold.of(context);
                  scaffold.hideCurrentSnackBar();

                  if (model.error != null) {
                    scaffold.showSnackBar(SnackBar(
                      content: Text(model.error),
                    ));
                  }
                });

                if (model.totalBox == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  children: <Widget>[
                    Text(
                      model.totalBox,
                      style: TextStyle(
                        fontSize: 36,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '更新于：${model.updateInfo}',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                        top: 16,
                      ),
                      child: BoxTable(),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class BoxTableSource extends DataTableSource {
  List<Box> _boxs;

  BoxTable(List<Box> boxs) {
    _boxs = boxs;
  }

  @override
  DataRow getRow(int index) {
    if (index >= _boxs.length) return null;

    final Box box = _boxs[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text(box.movieName)),
        DataCell(Text(box.boxInfo.toString())),
      ],
    );
  }

  @override
  int get rowCount => _boxs.length;

  @override
  int get selectedRowCount => 0;

  @override
  bool get isRowCountApproximate => false;
}

class BoxTable extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BoxTableState();
  }
}

class BoxTableState extends State<BoxTable> {
  bool _sortAscending = false;

  void _sort(BoxInfoModel model, bool ascending) {
    model.sort(ascending);

    setState(() {
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BoxInfoModel>(
      builder: (context, child, model) {
        return DataTable(
          sortColumnIndex: 1,
          sortAscending: _sortAscending,
          columns: [
            DataColumn(
              label: Text(
                '影片',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '票房(万)',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              numeric: true,
              onSort: (int columnIndex, bool ascending) =>
                  _sort(model, ascending),
            ),
          ],
          rows: model.boxs.map<DataRow>((Box box) {
            return DataRow(
              cells: <DataCell>[
                DataCell(Container(
                  // width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        box.movieName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${box.releaseInfo} ${box.sumBoxInfo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )),
                DataCell(Text(
                  box.boxInfo.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
