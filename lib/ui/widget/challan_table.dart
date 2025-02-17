import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:rajwada_app/ui/screen/view_challan_data.dart';
import '../../core/model/challan_list.dart';
import '../screen/add_challan.dart';

class ChallanTable extends StatefulWidget {
  final List<ChallanItem?> challanItems;
  final ScrollController controllScroll;

  const ChallanTable({super.key, required this.challanItems,required this.controllScroll});

  @override
  _ChallanTableState createState() => _ChallanTableState();
}

class _ChallanTableState extends State<ChallanTable> {
  bool _isAscending = true;
  String _sortColumn = "documentDate";
  List<ChallanItem?> _sortedChallanItems = [];

  @override
  void initState() {
    super.initState();
    _sortedChallanItems = List.from(widget.challanItems); // Initialize with the original data
  }

  void _sortList(String columnKey) {
    setState(() {
      if (_sortColumn == columnKey) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = columnKey;
        _isAscending = true;
      }

      _sortedChallanItems.sort((a, b) {
        var aValue = _getColumnValue(a, columnKey);
        var bValue = _getColumnValue(b, columnKey);

        if (aValue is String && bValue is String) {
          return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is int && bValue is int) {
          return _isAscending ? aValue - bValue : bValue - aValue;
        } else if (aValue is DateTime && bValue is DateTime) {
          return _isAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        }
        return 0;
      });
    });
  }

  dynamic _getColumnValue(ChallanItem? item, String columnKey) {
    switch (columnKey) {
      case "documentDate":
        if (item?.documentDate is DateTime) {
          return item?.documentDate;
        } else if (item?.documentDate is String) {
          return DateTime.tryParse(item!.documentDate.toString()) ?? DateTime(2000, 1, 1);
        }
        return DateTime(2000, 1, 1); // Default fallback date
      case "tracking":
        return item?.trackingNo ?? "";
      case "vehicle":
        return item?.vechileNo ?? "";
      case "supplier":
        return item?.supplierName?.toString() ?? "";
      default:
        return "";
    }
  }

  Widget tableHeader(String title, String columnKey, int flex) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => _sortList(columnKey), // ✅ Trigger sorting
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            if (_sortColumn == columnKey) // ✅ Show arrow only for sorted column
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(
                  _isAscending ? Icons.arrow_upward : Icons.arrow_downward, // ✅ Dynamic arrow
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget tableCell(String text, {int flex = 1, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // Table Header
          Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                tableHeader("#", "index", 1),       // Smallest flex
                tableHeader("Document Date", "documentDate", 5), // ✅ Fix columnKey
                tableHeader("Tracking No", "tracking", 4),
                tableHeader("Vehicle No", "vehicle", 4),
                tableHeader("Supplier Name", "supplier", 4),
              ],
            ),
          ),

          // Table Rows
          Expanded(
            child: ListView.builder(
              controller: widget.controllScroll,
              itemCount: _sortedChallanItems.length,
              itemBuilder: (context, index) {
                if (index == _sortedChallanItems.length) {
                  return const Center(child: CircularProgressIndicator()); // ✅ Show loader at the end
                }
                final item = _sortedChallanItems[index]; // ✅ Access item safely
                
                return Slidable(
                  key: ValueKey(item?.id), // Unique key for each item
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(), // Slide animation
                    children: [
                      // ✅ View Button
                      SlidableAction(
                        onPressed: (context) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewChallanScreen(challanId: item?.id ?? 0, challanData: item),
                            ),
                          );
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.visibility,
                        label: 'View',
                      ),
                      // ✅ Edit Button
                      SlidableAction(
                        onPressed: (context) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChallanEntryScreen(isEdit: true, challanId: item?.id ?? 0),
                            ),
                          );
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        tableCell((index + 1).toString(), flex: 1),
                        tableCell(
                            item?.documentDate is DateTime
                                ? DateFormat('yyyy-MM-dd')
                                    .format(item!.documentDate as DateTime)
                                : (item?.documentDate is String
                                    ? DateFormat('yyyy-MM-dd').format(
                                        DateTime.tryParse(item!.documentDate
                                                .toString()) ??
                                            DateTime(2000, 1, 1),
                                      )
                                    : "N/A"),
                            flex: 4),
                        tableCell(item?.trackingNo ?? "N/A", flex: 4),
                        tableCell(item?.vechileNo ?? "N/A", flex: 4),
                        tableCell(item?.supplierName?.toString() ?? "N/A",
                            flex: 4),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
