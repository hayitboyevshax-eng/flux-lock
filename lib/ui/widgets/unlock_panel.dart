import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/security_service.dart';
import '../../core/strings.dart';
import 'pattern_lock.dart';
import 'pin_pad.dart';

/// PIN / Chizma paneli. Hech narsa o'rnatilmagan bo'lsa — "o'rnatish" rejimi.
class UnlockPanel extends StatefulWidget {
  const UnlockPanel({super.key, required this.onUnlocked});
  final VoidCallback onUnlocked;

  @override
  State<UnlockPanel> createState() => _UnlockPanelState();
}

class _UnlockPanelState extends State<UnlockPanel> {
  late final SecurityService _sec = context.read<SecurityService>();
  bool _pattern = false, _hasPin = false, _hasPat = false;
  String? _first;
  String _msg = '';
  int _fails = 0;
  DateTime? _lockedUntil;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await _sec.hasPin, b = await _sec.hasPattern;
    if (mounted) setState(() => (_hasPin, _hasPat) = (a, b));
  }

  bool get _has => _pattern ? _hasPat : _hasPin;

  String _title(S t) {
    if (_has) return t.t(_pattern ? 'drawPattern' : 'enterPin');
    if (_first == null) return t.t(_pattern ? 'newPattern' : 'newPin');
    return t.t(_pattern ? 'confirmPattern' : 'confirmPin');
  }

  Future<bool> _submit(String v) async {
    final t = S.of(context);
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      setState(() => _msg = t.t('locked'));
      return false;
    }
    if (!_has) {
      if (_first == null) {
        setState(() {
          _first = v;
          _msg = '';
        });
        return true;
      }
      if (_first == v) {
        _pattern ? await _sec.setPattern(v) : await _sec.setPin(v);
        widget.onUnlocked();
        return true;
      }
      setState(() {
        _first = null;
        _msg = t.t('mismatch');
      });
      return false;
    }
    final ok = _pattern ? await _sec.checkPattern(v) : await _sec.checkPin(v);
    if (ok) {
      widget.onUnlocked();
      return true;
    }
    _fails++;
    if (_fails >= 5) {
      _fails = 0;
      _lockedUntil = DateTime.now().add(const Duration(seconds: 30));
    }
    if (mounted) setState(() => _msg = t.t('wrong'));
    return false;
  }

  void _switch(bool pattern) => setState(() {
        _pattern = pattern;
        _first = null;
        _msg = '';
      });

  @override
  Widget build(BuildContext context) {
    final t = S.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          color: Colors.black.withAlpha(95),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white38, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                      label: Text(t.t('pin')),
                      selected: !_pattern,
                      onSelected: (_) => _switch(false)),
                  const SizedBox(width: 10),
                  ChoiceChip(
                      label: Text(t.t('pattern')),
                      selected: _pattern,
                      onSelected: (_) => _switch(true)),
                ],
              ),
              const SizedBox(height: 14),
              Text(_title(t), style: const TextStyle(fontSize: 17, color: Colors.white)),
              SizedBox(
                height: 24,
                child: Text(_msg,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFFF8A8A))),
              ),
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: _pattern
                        ? PatternLock(
                            key: const ValueKey('pattern'),
                            onSubmit: (l) => _submit(l.join('-')))
                        : PinPad(key: const ValueKey('pin'), onSubmit: _submit),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
