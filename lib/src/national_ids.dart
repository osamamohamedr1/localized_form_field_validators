/// Validation rules for national ID numbers. Used by
/// `FormValidators.nationalId`; not part of the public API.
///
/// Each function receives the trimmed value with spaces and dashes removed.
library;

final RegExp _digitsOnly = RegExp(r'^\d+$');

/// Egyptian governorate codes, plus `88` for people born abroad.
const Set<String> _egyptianGovernorates = {
  '01', '02', '03', '04', // Cairo, Alexandria, Port Said, Suez
  '11', '12', '13', '14', '15', '16', '17', '18', '19', // Delta and Canal
  '21', '22', '23', '24', '25', '26', '27', '28', '29', // Upper Egypt
  '31', '32', '33', '34', '35', // Frontier governorates
  '88', // Born abroad
};

/// Weights for the first 11 digits of a Kuwaiti civil ID.
const List<int> _kuwaitWeights = [2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];

bool _isDigits(String id, int length) =>
    id.length == length && _digitsOnly.hasMatch(id);

int _digit(String id, int index) => id.codeUnitAt(index) - 0x30;

int _number(String id, int start, int end) =>
    int.parse(id.substring(start, end));

/// Whether [id] passes the Luhn check, doubling every second digit from the
/// right.
bool _passesLuhn(String id) {
  var sum = 0;
  for (var i = 0; i < id.length; i++) {
    var digit = _digit(id, id.length - 1 - i);
    if (i.isOdd) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
  }
  return sum % 10 == 0;
}

/// Whether [year], [month] and [day] form a real date no later than [today].
bool _isPastDate(int year, int month, int day, DateTime today) {
  final date = DateTime(year, month, day);
  return date.year == year &&
      date.month == month &&
      date.day == day &&
      !date.isAfter(today);
}

/// The century of a birth year encoded by a leading `2` (1900s) or `3`
/// (2000s) digit, or null for any other digit.
int? _century(String id) => switch (id[0]) {
  '2' => 1900,
  '3' => 2000,
  _ => null,
};

/// Egypt (الرقم القومي): 14 digits; century digit; a real birth date that is
/// not in the future; a known governorate code. The check digit is not
/// verified because its algorithm is not published.
bool isValidEgyptianNationalId(String id, {DateTime? today}) {
  if (!_isDigits(id, 14)) return false;
  final century = _century(id);
  if (century == null) return false;
  final year = century + _number(id, 1, 3);
  if (!_isPastDate(
    year,
    _number(id, 3, 5),
    _number(id, 5, 7),
    today ?? DateTime.now(),
  )) {
    return false;
  }
  return _egyptianGovernorates.contains(id.substring(7, 9));
}

/// Saudi Arabia (national ID or Iqama): 10 digits starting with `1`
/// (citizen) or `2` (resident); a valid Luhn check digit.
bool isValidSaudiNationalId(String id) {
  if (!_isDigits(id, 10) || (id[0] != '1' && id[0] != '2')) return false;
  return _passesLuhn(id);
}

/// Qatar (QID): 11 digits; century digit; a birth year that is not in the
/// future; a nationality code other than `000`.
bool isValidQatarNationalId(String id, {DateTime? today}) {
  if (!_isDigits(id, 11)) return false;
  final century = _century(id);
  if (century == null) return false;
  if (century + _number(id, 1, 3) > (today ?? DateTime.now()).year) {
    return false;
  }
  return id.substring(3, 6) != '000';
}

/// United Arab Emirates (Emirates ID): 15 digits starting with `784`; a
/// birth year from 1900 that is not in the future; a valid Luhn check digit.
bool isValidUaeNationalId(String id, {DateTime? today}) {
  if (!_isDigits(id, 15) || !id.startsWith('784')) return false;
  final year = _number(id, 3, 7);
  if (year < 1900 || year > (today ?? DateTime.now()).year) return false;
  return _passesLuhn(id);
}

/// Kuwait (civil ID): 12 digits; century digit; a real birth date that is
/// not in the future; a valid weighted check digit.
bool isValidKuwaitNationalId(String id, {DateTime? today}) {
  if (!_isDigits(id, 12)) return false;
  final century = _century(id);
  if (century == null) return false;
  if (!_isPastDate(
    century + _number(id, 1, 3),
    _number(id, 3, 5),
    _number(id, 5, 7),
    today ?? DateTime.now(),
  )) {
    return false;
  }
  var sum = 0;
  for (var i = 0; i < _kuwaitWeights.length; i++) {
    sum += _digit(id, i) * _kuwaitWeights[i];
  }
  final check = 11 - sum % 11;
  return check < 10 && check == _digit(id, 11);
}

/// Bahrain (CPR): 9 digits whose third and fourth digits are a birth month.
bool isValidBahrainNationalId(String id) {
  if (!_isDigits(id, 9)) return false;
  final month = _number(id, 2, 4);
  return month >= 1 && month <= 12;
}

/// Libya (الرقم الوطني): 12 digits; `1` or `2` first; a four-digit birth year
/// from 1900 that is not in the future.
bool isValidLibyaNationalId(String id, {DateTime? today}) {
  if (!_isDigits(id, 12) || (id[0] != '1' && id[0] != '2')) return false;
  final year = _number(id, 1, 5);
  return year >= 1900 && year <= (today ?? DateTime.now()).year;
}

/// Palestine: 9 digits with a valid Luhn check digit.
bool isValidPalestineNationalId(String id) =>
    _isDigits(id, 9) && _passesLuhn(id);

/// Morocco (CIN or CNIE): one or two letters followed by 1 to 6 digits.
bool isValidMoroccoNationalId(String id) =>
    RegExp(r'^[A-Za-z]{1,2}\d{1,6}$').hasMatch(id);

/// Algeria (NIN): 18 digits.
bool isValidAlgeriaNationalId(String id) => _isDigits(id, 18);

/// Iraq (unified national card): 12 digits.
bool isValidIraqNationalId(String id) => _isDigits(id, 12);

/// Jordan (الرقم الوطني): 10 digits.
bool isValidJordanNationalId(String id) => _isDigits(id, 10);

/// Syria (الرقم الوطني): 11 digits.
bool isValidSyriaNationalId(String id) => _isDigits(id, 11);

/// Tunisia (CIN): 8 digits.
bool isValidTunisiaNationalId(String id) => _isDigits(id, 8);
