Widget _buildTypeSelector() {
    return DropdownButton<String>(
      value: _rankingType,
      items: [
        DropdownMenuItem(value: 'day', child: Text('日別')),
        DropdownMenuItem(value: 'month', child: Text('月別')),
        DropdownMenuItem(value: 'year', child: Text('年別')),
        DropdownMenuItem(value: 'total', child: Text('総数')),
      ],
      onChanged: (value) {
        setState(() {
          _rankingType = value!;
        }

Widget _buildDaySelector() {
    return DropdownButton<String>(
      value: _selectedDate,
      items: _availableDates.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDate = value!;
        }

Widget _buildMonthSelector() {
    return DropdownButton<String>(
      value: _selectedMonth,
      items: _availableMonths.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMonth = value!;
        }

Widget _buildYearSelector() {
    return DropdownButton<String>(
      value: _selectedYear,
      items: _availableYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
      onChanged: (value) {
        setState(() {
          _selectedYear = value!;
        }

Widget _buildRankingHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTypeSelector(),
          const SizedBox(width: 16),
          _buildDateSelector(),
          const SizedBox(width: 16),
          if (_rankingType != 'day')
            Text(
              '※\${_getReferenceDate()}時点',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

Widget _buildDateSelector() {
    switch (_rankingType) {
      case 'day':
        return _buildDaySelector();
      case 'month':
        return _buildMonthSelector();
      case 'year':
        return _buildYearSelector();
      default:
        return const SizedBox();
    }

Widget _buildDateSelector() {
    if (_rankingType == 'day') {
      return _buildDatePicker();
    }