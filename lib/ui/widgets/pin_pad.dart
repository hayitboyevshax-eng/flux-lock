import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// onSubmit true => to'g'ri (tozalanadi), false => xato (silkinadi va tozalanadi).
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.onSubmit, this.length = 4});
  final Future<bool> Function(String pin) onSubmit;
  final int length;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  String _v = '';
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _tap(String d) async {
    if (_v.length >= widget.length) return;
    HapticFeedback.selectionClick();
    setState(() => _v += d);
    if (_v.length == widget.length) {
      final ok = await widget.onSubmit(_v);
      if (!mounted) return;
      if (!ok) {
        HapticFeedback.heavyImpact();
        await _shake.forward(from: 0);
      }
      if (mounted) setState(() => _v = '');
    }
  }

  void _back() {
    if (_v.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _v = _v.substring(0, _v.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (_, child) => Transform.translate(
            offset: Offset(sin(_shake.value * pi * 6) * 10 * (1 - _shake.value), 0),
            child: child,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 9),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _v.length ? Colors.white : Colors.transparent,
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '<'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final k in row)
                  _Key(
                    label: k,
                    onTap: k.isEmpty ? null : () => k == '<' ? _back() : _tap(k),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: SizedBox(
        width: 68,
        height: 68,
        child: label.isEmpty
            ? null
            : Material(
                color: Colors.white.withAlpha(30),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: Center(
                    child: label == '<'
                        ? const Icon(Icons.backspace_outlined, size: 22, color: Colors.white)
                        : Text(label,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white)),
                  ),
                ),
              ),
      ),
    );
  }
}
