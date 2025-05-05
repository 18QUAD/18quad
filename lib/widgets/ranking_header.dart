import 'package:flutter/material.dart';

class RankingHeader extends StatefulWidget {
  final Function(String) onTypeChanged;
  final Function(String) onDateChanged;
  final List<String> availableDates;
  final List<String> availableMonths;
  final List<String> availableYears;

  const RankingHeader({
    super.key,
    required this.onTypeChanged,
    required this.onDateChanged,
    required this.availableDates,
    required this.availableMonths,
    required this.availableYears,
  });

  @override
  State<RankingHeader> createState() => _RankingHeaderState();
}

class _RankingHeaderState extends State<RankingHeader> {
  String _rankingType = 'day';
  String _selectedDate = '';
  String _selectedMonth = '';
  String _selectedYear = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.availableDates.isNotEmpty ? widget.availableDates.first : '';
    _selectedMonth = widget.availableMonths.isNotEmpty ? widget.availableMonths.first : '';
    _selectedYear = widget.availableYears.isNotEmpty ? widget.availableYears.first : '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DropdownButton<String>(
            value: _rankingType,
            items: const [
              DropdownMenuItem(value: 'day', child: Text('日別')),
              DropdownMenuItem(value: 'month', child: Text('月別')),
              DropdownMenuItem(value: 'year', child: Text('年別')),
              DropdownMenuItem(value: 'total', child: Text('総数')),
            ],
            onChanged: (value) {
              setState(() {
                _rankingType = value!;
              });
              widget.onTypeChanged(value!);
            },
          ),
          const SizedBox(width: 16),
          _buildDateSelector(),
          const SizedBox(width: 16),
          if (_rankingType != 'day')
            Text(
              '※${_getReferenceDate()}時点',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    switch (_rankingType) {
      case 'day':
        return DropdownButton<String>(
          value: _selectedDate,
          items: widget.availableDates
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedDate = value!;
            });
            widget.onDateChanged(value!);
          },
        );
      case 'month':
        return DropdownButton<String>(
          value: _selectedMonth,
          items: widget.availableMonths
              .map((m) => DropdownMenuItem(value: m, child: Text(m)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedMonth = value!;
            });
            widget.onDateChanged(value!);
          },
        );
      case 'year':
        return DropdownButton<String>(
          value: _selectedYear,
          items: widget.availableYears
              .map((y) => DropdownMenuItem(value: y, child: Text(y)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedYear = value!;
            });
            widget.onDateChanged(value!);
          },
        );
      default:
        return const SizedBox();
    }
  }

  String _getReferenceDate() {
    if (_rankingType == 'month') return '$_selectedMonth-01';
    if (_rankingType == 'year') return '$_selectedYear-01-01';
    return _selectedDate;
  }
}
