import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/strength_bar.dart';

/// Password generator bottom sheet / screen.
class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key, this.onUsePassword});

  final ValueChanged<String>? onUsePassword;

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String _generatedPassword = '';
  double _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;

  final _history = <String>[];

  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _digits = '0123456789';
  static const _symbolsChars = '!@#\$%^&*()-_=+[]{};:,.<>?';

  final _random = Random.secure();

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  int get _strength {
    final length = _length.round();
    int score = 0;
    var pools = 0;
    if (_uppercase) pools++;
    if (_lowercase) pools++;
    if (_numbers) pools++;
    if (_symbols) pools++;

    if (pools >= 3) score++;
    if (length >= 12) score++;
    if (length >= 16) score++;
    if (pools == 4 && length >= 16) score++;
    return score.clamp(1, 4);
  }

  /// Generate a cryptographically-strong password.
  void _regenerate() {
    final length = _length.round();
    final pools = <String>[
      if (_uppercase) _upper,
      if (_lowercase) _lower,
      if (_numbers) _digits,
      if (_symbols) _symbolsChars,
    ];
    if (pools.isEmpty) {
      setState(() => _generatedPassword = '');
      return;
    }

    final buffer = StringBuffer();
    // Guarantee at least one char from each selected pool
    for (final pool in pools) {
      buffer.write(pool[_random.nextInt(pool.length)]);
    }
    // Fill the rest randomly
    final all = pools.join();
    while (buffer.length < length) {
      buffer.write(all[_random.nextInt(all.length)]);
    }
    // Shuffle to avoid a predictable pattern
    final chars = buffer.toString().split('');
    for (var i = chars.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }

    final result = chars.join();
    setState(() {
      _generatedPassword = result;
      if (!_history.contains(result)) {
        _history.insert(0, result);
        if (_history.length > 5) _history.removeLast();
      }
    });
  }

  void _copyPassword() {
    if (_generatedPassword.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password copied'),
        backgroundColor: AppTheme.primary,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Drag handle + header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Generator',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                color: AppTheme.surfaceContainerHighest,
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Generated password display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _generatedPassword,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 20,
                                  color: AppTheme.primary,
                                  letterSpacing: 0.15 * 20,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _copyPassword,
                              icon: const Icon(Icons.content_copy, size: 20),
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Regenerate
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _regenerate,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Regenerate'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            textStyle: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Strength
                      StrengthBar(strength: _strength),
                      const SizedBox(height: 24),

                      // Length slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Length',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _length.round().toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _length,
                        min: 4,
                        max: 64,
                        divisions: 60,
                        activeColor: AppTheme.primary,
                        inactiveColor: AppTheme.surfaceContainerHigh,
                        onChanged: (v) => setState(() => _length = v),
                        onChangeEnd: (_) => _regenerate(),
                      ),
                      const SizedBox(height: 16),

                      // Toggles
                      _ToggleRow(
                        label: 'Uppercase (A-Z)',
                        value: _uppercase,
                        onChanged: (v) {
                          setState(() => _uppercase = v);
                          _regenerate();
                        },
                      ),
                      _ToggleRow(
                        label: 'Lowercase (a-z)',
                        value: _lowercase,
                        onChanged: (v) {
                          setState(() => _lowercase = v);
                          _regenerate();
                        },
                      ),
                      _ToggleRow(
                        label: 'Numbers (0-9)',
                        value: _numbers,
                        onChanged: (v) {
                          setState(() => _numbers = v);
                          _regenerate();
                        },
                      ),
                      _ToggleRow(
                        label: 'Symbols (!@#...)',
                        value: _symbols,
                        onChanged: (v) {
                          setState(() => _symbols = v);
                          _regenerate();
                        },
                      ),
                      const SizedBox(height: 24),

                      // History
                      Text(
                        'Recent Passwords',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final p in _history)
                            _HistoryChip(
                              p,
                              onTap: () => setState(() {
                                _generatedPassword = p;
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Use button
                      ElevatedButton(
                        onPressed: () {
                          widget.onUsePassword?.call(_generatedPassword);
                          Navigator.pop(context);
                        },
                        child: const Text('Use Password'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
            inactiveTrackColor: AppTheme.surfaceContainerHigh,
          ),
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip(this.password, {this.onTap});

  final String password;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        password,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
      ),
      onPressed: onTap,
      backgroundColor: AppTheme.surfaceContainer,
      side: BorderSide.none,
    );
  }
}
