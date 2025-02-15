import 'package:flutter/material.dart';
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
  String _sortColumn = "project";
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
        }
        return 0;
      });
    });
  }

  dynamic _getColumnValue(ChallanItem? item, String columnKey) {
    switch (columnKey) {
      case "project":
        return item?.projectName ?? "";
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
      flex: flex, // Individual flex for each column
      child: InkWell(
        onTap: () {
          if (columnKey == "project") {
            _sortList(columnKey);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
            ),
            if (columnKey == "project") // Show sort icon only for Project column
              Row(
                children: [
                  const SizedBox(width: 5),
                  Icon(
                    _sortColumn == columnKey
                        ? (_isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                        : Icons.swap_vert,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
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
                tableHeader("Project", "project", 3), // Larger flex
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
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChallanEntryScreen(isEdit: true,challanId: _sortedChallanItems[index]?.id ?? 0), // Default to 0 if null
                      ),
                    );
                  },
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
                        tableCell(item?.projectName ?? "N/A", flex: 3, isBold: true),
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
