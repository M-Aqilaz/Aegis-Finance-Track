import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

enum PinLockMode { unlock, setup, change }

class PinLockScreen extends StatefulWidget {
  final StorageService storageService;
  final PinLockMode mode;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const PinLockScreen({
    super.key,
    required this.storageService,
    this.mode = PinLockMode.unlock,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  String _inputPin = '';
  String _firstPin = '';
  int _step = 0; // For setup (0: enter, 1: confirm), For change (0: old, 1: new, 2: confirm)
  String? _errorMessage;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String digit) {
    if (_inputPin.length >= 4) return;
    HapticFeedback.lightImpact();

    setState(() {
      _errorMessage = null;
      _inputPin += digit;
    });

    if (_inputPin.length == 4) {
      _handleCompletedPin(_inputPin);
    }
  }

  void _onDelete() {
    if (_inputPin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _errorMessage = null;
      _inputPin = _inputPin.substring(0, _inputPin.length - 1);
    });
  }

  Future<void> _handleCompletedPin(String pin) async {
    switch (widget.mode) {
      case PinLockMode.unlock:
        if (widget.storageService.verifyPin(pin)) {
          HapticFeedback.mediumImpact();
          widget.storageService.unlockApp();
          widget.onSuccess?.call();
        } else {
          _triggerError('PIN salah, silakan coba lagi');
        }
        break;

      case PinLockMode.setup:
        if (_step == 0) {
          setState(() {
            _firstPin = pin;
            _inputPin = '';
            _step = 1;
          });
        } else {
          if (pin == _firstPin) {
            await widget.storageService.setPin(pin);
            HapticFeedback.mediumImpact();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🛡️ PIN Pengaman berhasil diaktifkan!'),
                  backgroundColor: AppTheme.cyberMint,
                ),
              );
              widget.onSuccess?.call();
              Navigator.of(context).maybePop();
            }
          } else {
            _triggerError('PIN konfirmasi tidak cocok. Ulangi kembali.');
            setState(() {
              _step = 0;
              _firstPin = '';
            });
          }
        }
        break;

      case PinLockMode.change:
        if (_step == 0) {
          if (widget.storageService.verifyPin(pin)) {
            setState(() {
              _inputPin = '';
              _step = 1;
            });
          } else {
            _triggerError('PIN lama salah');
          }
        } else if (_step == 1) {
          setState(() {
            _firstPin = pin;
            _inputPin = '';
            _step = 2;
          });
        } else {
          if (pin == _firstPin) {
            await widget.storageService.setPin(pin);
            HapticFeedback.mediumImpact();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🛡️ PIN Pengaman berhasil diperbarui!'),
                  backgroundColor: AppTheme.cyberMint,
                ),
              );
              widget.onSuccess?.call();
              Navigator.of(context).maybePop();
            }
          } else {
            _triggerError('PIN konfirmasi tidak cocok.');
            setState(() {
              _step = 1;
              _firstPin = '';
            });
          }
        }
        break;
    }
  }

  void _triggerError(String message) {
    HapticFeedback.heavyImpact();
    setState(() {
      _errorMessage = message;
      _inputPin = '';
    });
    _shakeController.forward(from: 0.0);
  }

  String _getTitle() {
    switch (widget.mode) {
      case PinLockMode.unlock:
        return 'AEGIS SECURITY VAULT';
      case PinLockMode.setup:
        return _step == 0 ? 'BUAT PIN PENGAMAN' : 'KONFIRMASI PIN';
      case PinLockMode.change:
        if (_step == 0) return 'VERIFIKASI PIN LAMA';
        if (_step == 1) return 'BUAT PIN BARU';
        return 'KONFIRMASI PIN BARU';
    }
  }

  String _getSubtitle() {
    switch (widget.mode) {
      case PinLockMode.unlock:
        return 'Masukkan PIN Pengaman Anda';
      case PinLockMode.setup:
        return _step == 0
            ? 'Tentukan 4 digit angka rahasia'
            : 'Masukkan kembali 4 digit PIN yang sama';
      case PinLockMode.change:
        if (_step == 0) return 'Masukkan PIN Anda saat ini';
        if (_step == 1) return 'Masukkan 4 digit PIN baru';
        return 'Masukkan kembali PIN baru untuk konfirmasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar for Setup / Change mode (Close button)
            if (widget.mode != PinLockMode.unlock)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () {
                        widget.onCancel?.call();
                        Navigator.of(context).maybePop();
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              )
            else
              const SizedBox(height: 24),

            const Spacer(),

            // Aegis Shield Emblem & Security Badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.cyberMint.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyberMint.withValues(alpha: 0.3),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield_rounded,
                    size: 48,
                    color: AppTheme.cyberMint,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Header Title
            Text(
              _getTitle(),
              style: const TextStyle(
                color: AppTheme.cyberMint,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _getSubtitle(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 4-Dot Indicators with Shake Animation
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final double offset = 16 *
                    (1 - _shakeController.value) *
                    (0.5 - ((_shakeController.value * 5).floor() % 2 == 0 ? 0 : 1));
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _inputPin.length;
                  final isError = _errorMessage != null;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: isFilled ? 18 : 14,
                    height: isFilled ? 18 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isError
                          ? AppTheme.neonCoral
                          : (isFilled ? AppTheme.cyberMint : Colors.white.withValues(alpha: 0.12)),
                      border: Border.all(
                        color: isError
                            ? AppTheme.neonCoral
                            : (isFilled
                                ? AppTheme.cyberMint
                                : Colors.white.withValues(alpha: 0.3)),
                        width: 1.5,
                      ),
                      boxShadow: isFilled
                          ? [
                              BoxShadow(
                                color: (isError ? AppTheme.neonCoral : AppTheme.cyberMint)
                                    .withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
            ),

            // Error Message
            const SizedBox(height: 16),
            SizedBox(
              height: 20,
              child: _errorMessage != null
                  ? Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppTheme.neonCoral,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),

            const Spacer(),

            // Custom Tactile Circular Numpad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _buildNumRow(['1', '2', '3'], ['', 'ABC', 'DEF']),
                  const SizedBox(height: 16),
                  _buildNumRow(['4', '5', '6'], ['GHI', 'JKL', 'MNO']),
                  const SizedBox(height: 16),
                  _buildNumRow(['7', '8', '9'], ['PQRS', 'TUV', 'WXYZ']),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Empty placeholder on left to balance the zero key in center
                      const SizedBox(width: 72, height: 72),

                      // Zero
                      _buildNumKey('0', '+'),

                      // Right Action: Backspace
                      _buildActionKey(
                        icon: Icons.backspace_outlined,
                        label: 'HAPUS',
                        onTap: _onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Discreet Help / Forgot Option for Unlock mode
            if (widget.mode == PinLockMode.unlock)
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.surfaceCardElevated,
                      title: const Row(
                        children: [
                          Icon(Icons.lock_reset_rounded, color: AppTheme.solarAmber),
                          SizedBox(width: 8),
                          Text(
                            'Lupa PIN Pengaman?',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Demi keamanan privasi Anda, jika Anda lupa PIN, Anda dapat memulihkan akses dengan merestore file backup JSON Anda atau menghapus data aplikasi dari Pengaturan HP.',
                        style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Mengerti', style: TextStyle(color: AppTheme.cyberMint)),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Lupa PIN Pengaman?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildNumRow(List<String> digits, List<String> subs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (i) => _buildNumKey(digits[i], subs[i])),
    );
  }

  Widget _buildNumKey(String digit, String sub) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(digit),
        borderRadius: BorderRadius.circular(36),
        splashColor: AppTheme.cyberMint.withValues(alpha: 0.2),
        highlightColor: AppTheme.cyberMint.withValues(alpha: 0.1),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceCardElevated,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        splashColor: AppTheme.cyberMint.withValues(alpha: 0.2),
        highlightColor: AppTheme.cyberMint.withValues(alpha: 0.1),
        child: SizedBox(
          width: 72,
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.cyberMint, size: 26),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.cyberMint.withValues(alpha: 0.7),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
