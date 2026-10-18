/// IBAN validation. Used by `FormValidators.iban`; not part of the public
/// API.
library;

final RegExp _ibanFormat = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$');

/// IBAN lengths from the SWIFT IBAN registry for Arab countries and some
/// common others. IBANs from countries not listed here are checked for the
/// general format, a length of 15 to 34 and the checksum.
const Map<String, int> _ibanLengths = {
  // Arab countries.
  'AE': 23, 'BH': 22, 'EG': 29, 'IQ': 23, 'JO': 30, 'KW': 30, 'LB': 28,
  'LY': 25, 'PS': 29, 'QA': 29, 'SA': 24, 'SD': 18, 'TN': 24,
  // Others.
  'AT': 20, 'BE': 16, 'CH': 21, 'DE': 22, 'ES': 24, 'FR': 27, 'GB': 22,
  'IT': 27, 'NL': 18, 'TR': 26,
};

/// Whether [iban] is a valid IBAN, given in upper case without spaces.
///
/// Checks the format, the length (exact for the countries in
/// [_ibanLengths], otherwise 15 to 34), that it is from [countryCode] when
/// given, and the ISO 7064 mod-97 checksum.
bool isValidIban(String iban, {String? countryCode}) {
  if (!_ibanFormat.hasMatch(iban)) return false;
  final country = iban.substring(0, 2);
  if (countryCode != null && country != countryCode.trim().toUpperCase()) {
    return false;
  }
  final expectedLength = _ibanLengths[country];
  if (expectedLength != null
      ? iban.length != expectedLength
      : iban.length < 15 || iban.length > 34) {
    return false;
  }
  // Move the first four characters to the end, turn letters into numbers
  // (A = 10 ... Z = 35) and check that the result mod 97 is 1.
  final rearranged = iban.substring(4) + iban.substring(0, 4);
  var remainder = 0;
  for (final unit in rearranged.codeUnits) {
    final value = unit >= 0x41 ? unit - 0x41 + 10 : unit - 0x30;
    remainder = (remainder * (value >= 10 ? 100 : 10) + value) % 97;
  }
  return remainder == 1;
}
