import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:rajwada_app/ui/screen/view_challan_data.dart';
import '../../core/model/challan_list.dart';
import '../screen/add_challan.dart';

class ChallanTable extends StatefulWidget {
  final List<ChallanItem> challanItems;
  final Function(int) fetchChallanData;
  final ScrollController controllScroll;
  final String userRole;
  final int currentPage; // ✅ Track the current page number

  const ChallanTable({super.key,
    required this.challanItems,
    required this.fetchChallanData,
    required this.controllScroll,
    required this.userRole,
    required this.currentPage,
  });

  @override
  _ChallanTableState createState() => _ChallanTableState();
}

class _ChallanTableState extends State<ChallanTable> {
  bool _isAscending = true;
  String _sortColumn = "documentDate";
  List<ChallanItem?> _sortedChallanItems = [];
  bool isLoading = false;
  List<ChallanItem?> challanListData = [];
  int currentPage = 1;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    widget.controllScroll.addListener(() {
      if (widget.controllScroll.position.pixels >=
          widget.controllScroll.position.maxScrollExtent - 200) {
        widget.fetchChallanData(widget.currentPage); // ✅ Fetch more data when scrolling near bottom
      }
    });
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
            padding: const EdgeInsets.symmetric(vertical: 10),
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
              controller: widget.controllScroll, // ✅ Attach controller
              itemCount: _sortedChallanItems.length + (isLoading ? 1 : 0), // +1 for the loader
              physics: const AlwaysScrollableScrollPhysics(), // ✅ Ensures scrolling even with fewer items
              primary: false, // ✅ Prevents conflicts if inside another scrollable widget
              itemBuilder: (context, index) {

                if (index == widget.challanItems.length) {
                  return isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }

                // if (index == _sortedChallanItems.length) {
                //   return isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox(); // ✅ Show loader only when loading
                // }

                final item = _sortedChallanItems[index];

                return Slidable(
                  key: ValueKey(item?.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
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
                      (widget.userRole == "New Civil Head" || item?.status == 3 || item?.status == 4 || item?.status == 6) ? const SizedBox.shrink() : SlidableAction(
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
                      ) ,
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
                                ? DateFormat('dd-MM-yyyy')
                                .format(item!.documentDate as DateTime)
                                : (item?.documentDate is String
                                ? DateFormat('dd-MM-yyyy').format(
                              DateTime.tryParse(item!.documentDate.toString()) ??
                                  DateTime(2000, 1, 1),
                            )
                                : "N/A"),
                            flex: 4),
                        tableCell(item?.trackingNo ?? "N/A", flex: 4),
                        tableCell(item?.vechileNo ?? "N/A", flex: 4),
                        tableCell(item?.supplierName?.toString() ?? "N/A", flex: 4),
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
