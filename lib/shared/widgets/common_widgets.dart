import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

Widget text(String value, {
  double size = 13,
  bool bold = false,
  bool sub = false,
  bool light = false,
  Color? color,
}) => Text(
  value,
  style: TextStyle(
    fontSize: size,
    height: 1.5,
    color: color ?? (light ? const Color(0xFFC5D0C3) : sub ? lightMuted : energyInk),
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
  ),
);

Widget heading(String value, {bool light = false}) => Padding(
  padding: const EdgeInsets.only(bottom: 7),
  child: Text(
    value,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: light ? Colors.white : energyInk,
    ),
  ),
);

Widget header(String title, String subtitle, {String? eyebrow, bool isCustomer = true}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      eyebrow ?? (isCustomer ? 'YOUR ENERGY, UNDERSTOOD' : 'FIELD WORKSPACE'),
      style: const TextStyle(
        color: lightMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    ),
    const SizedBox(height: 8),
    Text(
      title,
      style: const TextStyle(
        fontSize: 27,
        height: 1.15,
        letterSpacing: -1,
        color: energyInk,
        fontWeight: FontWeight.w700,
      ),
    ),
    const SizedBox(height: 10),
    text(subtitle, size: 12, sub: true),
  ],
);

Widget card(List<Widget> children, {bool glass = false, bool alert = false, double padding = 18}) => Container(
  margin: const EdgeInsets.only(top: 14),
  padding: EdgeInsets.all(padding),
  decoration: BoxDecoration(
    color: glass ? null : lightSurface,
    gradient: glass
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [glassTop, glassBottom],
          )
        : null,
    borderRadius: BorderRadius.circular(21),
    border: Border.all(
      color: alert ? alertWarn : glass ? glassBorder : lightLine,
    ),
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
);

Widget row(Widget left, Widget right) => Row(
  children: [
    Expanded(child: left),
    const SizedBox(width: 10),
    Flexible(child: Align(alignment: Alignment.centerRight, child: right)),
  ],
);

Widget rule({bool light = false}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 12),
  child: Divider(
    height: 1,
    color: light ? Colors.white.withAlpha(34) : lightLine,
  ),
);

Widget entry(String label, String value, [String subtitle = '']) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 13),
  child: Column(
    children: [
      row(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text(label),
            if (subtitle.isNotEmpty) text(subtitle, size: 12, sub: true),
          ],
        ),
        text(value, bold: true),
      ),
      const SizedBox(height: 12),
      Divider(height: 1, color: lightLine),
    ],
  ),
);

Widget chip(String label, [String tone = '', bool glass = false]) {
  Color color;
  if (glass) {
    color = const Color(0xFFD6E9D6);
  } else if (tone == 'warn') {
    color = const Color(0xFF936715);
  } else if (tone == 'danger') {
    color = alertDanger;
  } else if (tone == 'info') {
    color = alertInfo;
  } else {
    color = alertSuccess;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: glass ? Colors.white.withAlpha(19) : color.withAlpha(22),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

Widget button(
  String label, {
  String? to,
  VoidCallback? action,
  bool secondary = false,
  bool enabled = true,
}) => Padding(
  padding: const EdgeInsets.only(top: 14),
  child: SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: !enabled ? null : action ?? () {},
      style: TextButton.styleFrom(
        backgroundColor: secondary ? lightSurface : energyYellow,
        foregroundColor: secondary ? energyInk : energyInk,
        disabledForegroundColor: lightMuted,
        minimumSize: const Size(0, 49),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: secondary ? const BorderSide(color: lightLine) : BorderSide.none,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ),
  ),
);

Widget link(String label, String to, {bool light = false, VoidCallback? onTap}) => Align(
  alignment: Alignment.centerLeft,
  child: TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      foregroundColor: light ? energyYellow : const Color(0xFF7B5B00),
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      alignment: Alignment.centerLeft,
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  ),
);

Widget help(String value) => Container(
  margin: const EdgeInsets.only(top: 14),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: const Color(0xFFEDF0E6),
    borderRadius: BorderRadius.circular(12),
  ),
  child: text(value, size: 12, sub: true),
);

Widget bigNumber(String value, [String unit = '', double size = 49]) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: value,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w600,
            letterSpacing: -2,
            color: const Color(0xFFFAFCF8),
          ),
        ),
        TextSpan(
          text: ' $unit',
          style: const TextStyle(fontSize: 16, color: Color(0xFFCAD3C8)),
        ),
      ],
    ),
  ),
);

Widget mini(String label, String value, [String subtitle = '']) => card([
  text(label, size: 12, sub: true),
  const SizedBox(height: 7),
  text(value, size: 22, bold: true),
  if (subtitle.isNotEmpty) text(subtitle, size: 12, sub: true),
], padding: 15);

Widget grid(Widget a, Widget b) => Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [Expanded(child: a), const SizedBox(width: 11), Expanded(child: b)],
);

Widget progressBar(double value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 12),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: LinearProgressIndicator(
      value: value,
      minHeight: 8,
      color: energyYellow,
      backgroundColor: const Color(0xFFE7ECE3),
    ),
  ),
);

Widget chart(List<int> values, List<String> labels, {bool glass = false}) {
  final maximum = values.reduce((a, b) => a > b ? a : b);
  return Semantics(
    label: labels.asMap().entries.map((e) => '${e.value}: ${values[e.key]} kWh').join(', '),
    child: ExcludeSemantics(
      child: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 78,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    height: 78 * values[i] / maximum,
                    decoration: BoxDecoration(
                      color: i == 0 ? const Color(0xFF7D8A79) : energyYellow,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    ),
                  ),
                ),
              )),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: labels.map((l) => Expanded(
              child: Text(
                l,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: glass ? const Color(0xFFCBD6C7) : lightMuted,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget tabs(List<String> labels, String selected, ValueChanged<String> onChanged) => Container(
  margin: const EdgeInsets.only(top: 15),
  padding: const EdgeInsets.all(4),
  decoration: BoxDecoration(
    color: const Color(0xFFE7EAE2),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: labels.map((label) => Expanded(
      child: Semantics(
        selected: label == selected,
        child: TextButton(
          onPressed: () => onChanged(label),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            foregroundColor: label == selected ? energyInk : lightMuted,
            backgroundColor: label == selected ? lightSurface : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      ),
    )).toList(),
  ),
);

Widget label(String value) => Padding(
  padding: const EdgeInsets.only(top: 18, bottom: 8),
  child: text(value, size: 12, bold: true),
);

Widget field(
  String title,
  TextEditingController controller, {
  int lines = 1,
  bool required = true,
  bool numeric = false,
  bool password = false,
  bool email = false,
  String? hint,
  String? Function(String?)? validator,
  ValueChanged<String>? onChanged,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    label(title),
    TextFormField(
      controller: controller,
      maxLines: lines,
      obscureText: password,
      onChanged: onChanged,
      style: TextStyle(fontSize: numeric && title.contains('CURRENT') ? 36 : 14),
      keyboardType: numeric
          ? TextInputType.number
          : email
              ? TextInputType.emailAddress
              : lines > 1
                  ? TextInputType.multiline
                  : TextInputType.text,
      decoration: InputDecoration(hintText: hint),
      validator: validator ?? (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Please enter ${title.toLowerCase()}.';
        }
        if (email && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value ?? '')) {
          return 'Enter a valid email address.';
        }
        if (password && (value?.length ?? 0) < 8) {
          return 'Use at least 8 characters.';
        }
        return null;
      },
    ),
  ],
);

Widget dropdown(
  String title,
  String value,
  List<String> options,
  ValueChanged<String> changed,
) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    label(title),
    DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      items: options
          .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: (v) {
        if (v != null) changed(v);
      },
    ),
  ],
);