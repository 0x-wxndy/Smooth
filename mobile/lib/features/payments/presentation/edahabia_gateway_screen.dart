import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../payment_models.dart';
import 'payment_fulfillment.dart';

/// Mock Algérie Poste / Edahabia (SATIM) gateway page.
class EdahabiaGatewayScreen extends StatefulWidget {
  const EdahabiaGatewayScreen({super.key, required this.args});

  final PaymentCheckoutArgs args;

  @override
  State<EdahabiaGatewayScreen> createState() => _EdahabiaGatewayScreenState();
}

class _EdahabiaGatewayScreenState extends State<EdahabiaGatewayScreen> {
  final _cardCtrl = TextEditingController(text: '9900 0000 0000 0000');
  final _expCtrl = TextEditingController(text: '12/28');
  final _cvvCtrl = TextEditingController(text: '123');
  final _otpCtrl = TextEditingController();
  bool _processing = false;
  bool _otpStep = false;

  static const gold = Color(0xFFE8A317);
  static const postGreen = Color(0xFF006B3F);

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_otpStep) {
      setState(() => _otpStep = true);
      return;
    }
    if (_otpCtrl.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).enterOtp)),
      );
      return;
    }

    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    // Demo: OTP 0000 fails
    final fail = _otpCtrl.text.trim() == '0000';
    final ref = 'EDH-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    if (!fail) {
      await PaymentFulfillment.apply(context, widget.args, PaymentGateway.edahabia);
    }

    if (!mounted) return;
    context.pushReplacement(
      '/pay/result',
      extra: PaymentResultArgs(
        success: !fail,
        title: widget.args.title,
        amountCentimes: widget.args.amountCentimes,
        gateway: PaymentGateway.edahabia,
        purpose: widget.args.purpose,
        itemId: widget.args.itemId,
        aiTokens: widget.args.aiTokens,
        transactionRef: ref,
        message: fail ? S.of(context).paymentFailed : S.of(context).paymentSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final args = widget.args;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [postGreen, Color(0xFF0A8F55)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _processing ? null : () => context.pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        s.mockGateway,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'EDAHABIA',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Color(0xFF3A2A00),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SATIM',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.edahabiaSecure,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: gold.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(s.merchant, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        const Text('Smooth Hub', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                        const SizedBox(height: 12),
                        Text(args.title, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(
                          Money.format(args.amountCentimes),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: postGreen,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: 20),
                  if (!_otpStep) ...[
                    _Field(
                      label: s.cardNumber,
                      controller: _cardCtrl,
                      keyboard: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                        LengthLimitingTextInputFormatter(19),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _Field(
                            label: s.expiry,
                            controller: _expCtrl,
                            keyboard: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Field(
                            label: 'CVV',
                            controller: _cvvCtrl,
                            keyboard: TextInputType.number,
                            obscure: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        s.otpHint,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      label: s.otpCode,
                      controller: _otpCtrl,
                      keyboard: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (_processing)
                    const Center(child: CircularProgressIndicator(color: postGreen))
                  else
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: postGreen,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _otpStep ? s.confirmPayment : s.payNow,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    s.edahabiaDemoTip,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboard,
    this.obscure = false,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final bool obscure;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
