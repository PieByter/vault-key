import 'package:flutter/material.dart';
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
  String _generatedPassword = 'Yx9\$kP2#mN5*qR8';
  double _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;

  int get _strength {
    int score = 0;
    if (_uppercase) score++;
    if (_lowercase) score++;
    if (_numbers) score++;
    if (_symbols) score++;
    return score.clamp(1, 4);
  }

  void _regenerate() {
    // Placeholder — wire to actual generator
    setState(() {
      _generatedPassword = 'Xy7#mK2!pQ9\$rL4';
    });
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
                              onPressed: () {},
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
                      ),
                      const SizedBox(height: 16),

                      // Toggles
                      _ToggleRow(
                        label: 'Uppercase (A-Z)',
                        value: _uppercase,
                        onChanged: (v) => setState(() => _uppercase = v),
                      ),
                      _ToggleRow(
                        label: 'Lowercase (a-z)',
                        value: _lowercase,
                        onChanged: (v) => setState(() => _lowercase = v),
                      ),
                      _ToggleRow(
                        label: 'Numbers (0-9)',
                        value: _numbers,
                        onChanged: (v) => setState(() => _numbers = v),
                      ),
                      _ToggleRow(
                        label: 'Symbols (!@#...)',
                        value: _symbols,
                        onChanged: (v) => setState(() => _symbols = v),
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
                          _HistoryChip('Yx9\$kP2#mN5*qR8'),
                          _HistoryChip('Ab3@xK9!mP2#rL7'),
                          _HistoryChip('Zq1#wE5\$tY8*uJ4'),
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
  const _HistoryChip(this.password);

  final String password;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        password,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
      ),
      backgroundColor: AppTheme.surfaceContainer,
      side: BorderSide.none,
    );
  }
}
