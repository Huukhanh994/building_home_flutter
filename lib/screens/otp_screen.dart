import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../services/buildhome_api_client.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, this.devOtp});

  final String phone;

  /// Provided by API in non-production for dev convenience.
  final String? devOtp;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _otpLength = 6;
  static const _resendCooldown = 60;

  final _controllers = List.generate(_otpLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_otpLength, (_) => FocusNode());

  bool _loading = false;
  String? _error;
  int _resendSeconds = _resendCooldown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Auto-fill dev OTP
    if (widget.devOtp != null && widget.devOtp!.length == _otpLength) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (var i = 0; i < _otpLength; i++) { _controllers[i].text = widget.devOtp![i]; }
        _submit();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds <= 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == _otpLength) {
      // Handle paste of full OTP
      for (var i = 0; i < _otpLength && i < value.length; i++) { _controllers[i].text = value[i]; }
      _focusNodes[_otpLength - 1].requestFocus();
      _submit();
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_otp.length == _otpLength) _submit();
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _submit() async {
    final otp = _otp;
    if (otp.length < _otpLength) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.instance.verifyOtp(
        phone: widget.phone,
        otp: otp,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    } on Exception {
      setState(() => _error = 'Không kết nối được máy chủ');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;

    setState(() => _error = null);

    try {
      final devOtp = await AuthService.instance.sendOtp(widget.phone);
      _startTimer();

      if (devOtp != null && devOtp.length == _otpLength) {
        for (var i = 0; i < _otpLength; i++) { _controllers[i].text = devOtp[i]; }
        _submit();
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } on Exception {
      setState(() => _error = 'Không kết nối được máy chủ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildOtpFields(),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _buildErrorBanner(),
              ],
              const SizedBox(height: 32),
              _buildVerifyButton(),
              const SizedBox(height: 24),
              _buildResendRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final masked = widget.phone.length > 4
        ? '${widget.phone.substring(0, widget.phone.length - 4)}****'
        : widget.phone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập mã OTP',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Mã 6 chữ số đã gửi đến $masked',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_otpLength, (i) => _OtpBox(
        controller: _controllers[i],
        focusNode: _focusNodes[i],
        onChanged: (val) => _onDigitChanged(i, val),
        onBackspace: () => _onBackspace(i),
        enabled: !_loading,
      )),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (_loading || _otp.length < _otpLength) ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green500,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text('Xác nhận'),
      ),
    );
  }

  Widget _buildResendRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Chưa nhận được mã? ',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        if (_resendSeconds > 0)
          Text(
            'Gửi lại sau ${_resendSeconds}s',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          )
        else
          GestureDetector(
            onTap: _resend,
            child: Text(
              'Gửi lại',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.green500,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }
}

// ── OTP Box ──────────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6), // allow paste
          ],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.green500, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
