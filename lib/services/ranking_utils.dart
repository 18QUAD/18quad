String _getReferenceDate() {
    if (_rankingType == 'month') {
      return '\${_selectedMonth}01日';
    }