/// يحوّل مبلغاً رقمياً إلى كتابة بالحروف العربية، مع لاحقة "دينار جزائري" و"سنتيم".
/// منقول مباشرة من نسخة سطح المكتب (NumberToArabicWords.cs).
class NumberToArabicWords {
  static const List<String> _ones = [
    '', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة'
  ];
  static const List<String> _onesFeminine = [
    '', 'واحدة', 'اثنتان', 'ثلاث', 'أربع', 'خمس', 'ست', 'سبع', 'ثمان', 'تسع'
  ];
  static const List<String> _teens = [
    'عشرة', 'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر',
    'ستة عشر', 'سبعة عشر', 'ثمانية عشر', 'تسعة عشر'
  ];
  static const List<String> _tens = [
    '', '', 'عشرون', 'ثلاثون', 'أربعون', 'خمسون', 'ستون', 'سبعون', 'ثمانون', 'تسعون'
  ];
  static const List<String> _hundreds = [
    '', 'مائة', 'مائتان', 'ثلاثمائة', 'أربعمائة', 'خمسمائة',
    'ستمائة', 'سبعمائة', 'ثمانمائة', 'تسعمائة'
  ];

  static String convert(
    double amount, {
    String mainUnitSingular = 'دينار جزائري',
    String subUnitSingular = 'سنتيم',
  }) {
    amount = amount.abs();
    amount = double.parse(amount.toStringAsFixed(2));
    final integerPart = amount.floor();
    final fraction = ((amount - integerPart) * 100).round();

    final words = integerPart == 0 ? 'صفر' : _convertInteger(integerPart);
    final sb = StringBuffer()..write(words)..write(' ')..write(mainUnitSingular);

    if (fraction > 0) {
      sb.write(' و');
      sb.write(_convertInteger(fraction));
      sb.write(' ');
      sb.write(subUnitSingular);
    }

    return sb.toString();
  }

  static String _convertInteger(int number) {
    if (number == 0) return 'صفر';
    if (number < 0) return 'سالب ${_convertInteger(-number)}';

    final groups = <List<Object>>[
      [1000000000, 'مليار', 'ملياران', 'مليارات'],
      [1000000, 'مليون', 'مليونان', 'ملايين'],
      [1000, 'ألف', 'ألفان', 'آلاف'],
    ];

    final parts = <String>[];
    var remaining = number;

    for (final g in groups) {
      final value = g[0] as int;
      final singular = g[1] as String;
      final dual = g[2] as String;
      final plural = g[3] as String;

      final count = remaining ~/ value;
      remaining %= value;
      if (count <= 0) continue;

      if (count == 1) {
        parts.add(singular);
      } else if (count == 2) {
        parts.add(dual);
      } else if (count >= 3 && count <= 10) {
        parts.add('${_convertUnderThousand(count, feminine: true)} $plural');
      } else {
        parts.add('${_convertUnderThousand(count, feminine: false)} $singular');
      }
    }

    if (remaining > 0) {
      parts.add(_convertUnderThousand(remaining, feminine: false));
    }

    return parts.join(' و');
  }

  static String _convertUnderThousand(int number, {required bool feminine}) {
    if (number == 0) return '';
    final onesArr = feminine ? _onesFeminine : _ones;
    final sb = StringBuffer();

    final hundreds = number ~/ 100;
    final rest = number % 100;

    if (hundreds > 0) {
      sb.write(_hundreds[hundreds]);
      if (rest > 0) sb.write(' و');
    }

    if (rest >= 10 && rest <= 19) {
      sb.write(_teens[rest - 10]);
    } else {
      final tens = rest ~/ 10;
      final ones = rest % 10;

      if (tens > 0 && ones > 0) {
        sb.write(onesArr[ones]);
        sb.write(' و');
        sb.write(_tens[tens]);
      } else if (tens > 0) {
        sb.write(_tens[tens]);
      } else if (ones > 0) {
        sb.write(onesArr[ones]);
      }
    }

    return sb.toString();
  }
}
