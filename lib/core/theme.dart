import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFF0B1020);
  static const surface = Color(0xFF131A2E);
  static const violet = Color(0xFF7C3AED);
  static const indigo = Color(0xFF4F46E5);
  static const cyan = Color(0xFF22D3EE);
  static const teal = Color(0xFF2DD4BF);
  static const text = Color(0xFFE8ECF8);
  static const muted = Color(0xFF9AA4C0);
  static const grad = LinearGradient(colors: [violet, indigo]);
}

bool isMobile(BuildContext c) => MediaQuery.sizeOf(c).width < 700;
bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= 900;

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
        primary: C.violet, secondary: C.cyan, surface: C.surface),
    scaffoldBackgroundColor: C.bg,
  );
  return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: C.text, displayColor: C.text));
}

InputDecoration fieldDecoration(String label, {String? hint}) {
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w));
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color.fromRGBO(255, 255, 255, .06),
    enabledBorder: b(const Color.fromRGBO(255, 255, 255, .15)),
    focusedBorder: b(C.cyan, 2),
    errorBorder: b(Colors.redAccent),
    focusedErrorBorder: b(Colors.redAccent, 2),
    border: b(const Color.fromRGBO(255, 255, 255, .15)),
  );
}

void toast(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : C.indigo,
      behavior: SnackBarBehavior.floating,
    ));
}

String timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inDays > 0) return '${d.inDays}d ago';
  if (d.inHours > 0) return '${d.inHours}h ago';
  if (d.inMinutes > 0) return '${d.inMinutes}m ago';
  return 'just now';
}
