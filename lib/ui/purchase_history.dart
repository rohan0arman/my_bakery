/// The PurchaseHistoryPage class displays a table of the last 5 purchase records fetched from a cloud
/// storage backend.
import 'package:flutter/material.dart';
import 'package:my_bakery/backend/cloud_storage.dart';
import 'package:my_bakery/colors.dart';

class PurchaseHistoryPage extends StatelessWidget {
  PurchaseHistoryPage({super.key});

  final Future<List<PurchaseHistory>> _futurePurchaseHistory =
      fetchLastNthPurchaseRecords(10);

  @override
  Widget build(context) {
    return FutureBuilder<List<PurchaseHistory>>(
      future: _futurePurchaseHistory,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return const Icon(Icons.error);
        } else if (snapshot.hasData) {
          return HistoryTable(records: snapshot.data!);
        }
        return const RepaintBoundary(child: CircularProgressIndicator());
      },
    );
  }
}

class HistoryTable extends StatelessWidget {
  const HistoryTable({super.key, required this.records});
  final List<PurchaseHistory> records;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 15,
      headingTextStyle: const TextStyle(
        fontSize: 15.0,
        height: 1.0,
        color: Colors.blue,
        fontWeight: FontWeight.w500,
      ),
      columns: const [
        DataColumn(label: Text('DATE ', textAlign: TextAlign.start)),
        DataColumn(label: Text('NAME', textAlign: TextAlign.start)),
        DataColumn(label: Text('PREVIOUS', textAlign: TextAlign.center)),
        DataColumn(label: Text('ADDED', textAlign: TextAlign.center)),
        DataColumn(label: Text('RATE', textAlign: TextAlign.end)),
        DataColumn(label: Text('TOTAL', textAlign: TextAlign.end)),
      ],
      dataTextStyle: const TextStyle(
        fontSize: 12.5,
        color: Colors.grey,
      ),
      dataRowColor: MaterialStateProperty.all<Color?>(Colors.transparent),
      rows: List.generate(
          records.length,
          (index) => DataRow(cells: [
                DataCell(
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: Text(
                      records[index].date.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      records[index].name,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      records[index].previousQuantity.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      records[index].addedQuantity.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: Text(
                      records[index].rate.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: Text(
                      records[index].totalPrice.toString(),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ])),
    );
  }
}
