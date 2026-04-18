import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../services/buildhome_api_client.dart';
import '../theme/app_theme.dart';
import 'otp_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _validatePhone(String? val) {
    if (val == null || val.isEmpty) return 'Vui lòng nhập số điện thoại';
    final clean = val.trim();
    if (!RegExp(r'^(\+84|0)[0-9]{9}$').hasMatch(clean)) {
      return 'Số điện thoại không hợp lệ (VD: 0901234567)';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final phone = _phoneCtrl.text.trim();

    try {
      final devOtp = await AuthService.instance.sendOtp(phone);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: phone, devOtp: devOtp),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } on Exception {
      setState(() => _error = 'Không kết nối được máy chủ');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              _buildHeader(context),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPhoneField(),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _buildErrorBanner(),
                    ],
                    const SizedBox(height: 28),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.green500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.home_work_rounded,
            color: AppColors.green500,
            size: 28,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Đăng nhập\nBuildHome VN',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Nhập số điện thoại để nhận mã OTP',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+]'))],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      validator: _validatePhone,
      decoration: InputDecoration(
        labelText: 'Số điện thoại',
        hintText: '0901 234 567',
        prefixIcon: const Padding(
          padding: EdgeInsets.all(14),
          child: Text('🇻🇳', style: TextStyle(fontSize: 18)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.green500, width: 2),
        ),
      ),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
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
            : const Text('Gửi mã OTP'),
      ),
    );
  }
}
