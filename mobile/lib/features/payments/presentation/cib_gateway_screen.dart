import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money.dart';
import '../payment_models.dart';
import 'payment_fulfillment.dart';

/// Mock CIB (Carte Interbancaire / SATIM) gateway.
class CibGatewayScreen extends StatefulWidget {
  const CibGatewayScreen({super.key, required this.args});

  final PaymentCheckoutArgs args;

  @override
  State<CibGatewayScreen> createState() => _CibGatewayScreenState();
}

class _CibGatewayScreenState extends State<CibGatewayScreen> {
  final _cardCtrl = TextEditingController(text: '6280 0000 0000 0000');
  final _holderCtrl = TextEditingController(text: 'CLIENT DEMO');
  final _expCtrl = TextEditingController(text: '09/27');
  final _cvvCtrl = TextEditingController(text: '456');
  bool _processing = false;

  static const blue = Color(0xFF1E4D8C);

  @override
  void dispose() {
    _cardCtrl.dispose();
    _holderCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    await PaymentFulfillment.apply(context, widget.args, PaymentGateway.cib);
    if (!mounted) return;

    context.pushReplacement(
      '/pay/result',
      extra: PaymentResultArgs(
        success: true,
        title: widget.args.title,
        amountCentimes: widget.args.amountCentimes,
        gateway: PaymentGateway.cib,
        purpose: widget.args.purpose,
        itemId: widget.args.itemId,
        aiTokens: widget.args.aiTokens,
        transactionRef: 'CIB-${DateTime.now().millisecondsSinceEpoch % 1000000}',
        message: S.of(context).paymentSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CIB / SATIM', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(s.mockGateway, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [blue, Color(0xFF2A6BB8)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.amountToPay, style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 6),
                Text(
                  Money.format(widget.args.amountCentimes),
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(widget.args.title, style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _label(s.cardHolder),
          TextField(controller: _holderCtrl, textCapitalization: TextCapitalization.characters),
          const SizedBox(height: 12),
          _label(s.cardNumber),
          TextField(
            controller: _cardCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
              LengthLimitingTextInputFormatter(19),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(s.expiry),
                    TextField(controller: _expCtrl),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('CVV'),
                    TextField(
                      controller: _cvvCtrl,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_processing)
            const Center(child: CircularProgressIndicator())
          else
            FilledButton(
              onPressed: _pay,
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: Text(s.payNow, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          const SizedBox(height: 12),
          Text(
            s.cibDemoTip,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      );
}

/// Generic Visa/MC style mock.
class CardGatewayScreen extends StatefulWidget {
  const CardGatewayScreen({super.key, required this.args});

  final PaymentCheckoutArgs args;

  @override
  State<CardGatewayScreen> createState() => _CardGatewayScreenState();
}

class _CardGatewayScreenState extends State<CardGatewayScreen> {
  final _cardCtrl = TextEditingController(text: '4111 1111 1111 1111');
  final _nameCtrl = TextEditingController(text: 'SMOOTH DEMO');
  final _expCtrl = TextEditingController(text: '03/29');
  final _cvvCtrl = TextEditingController(text: '123');
  bool _processing = false;

  @override
  void dispose() {
    _cardCtrl.dispose();
    _nameCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    await PaymentFulfillment.apply(context, widget.args, PaymentGateway.card);
    if (!mounted) return;
    context.pushReplacement(
      '/pay/result',
      extra: PaymentResultArgs(
        success: true,
        title: widget.args.title,
        amountCentimes: widget.args.amountCentimes,
        gateway: PaymentGateway.card,
        purpose: widget.args.purpose,
        itemId: widget.args.itemId,
        aiTokens: widget.args.aiTokens,
        transactionRef: 'CARD-${DateTime.now().millisecondsSinceEpoch % 1000000}',
        message: S.of(context).paymentSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.cardPayment)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 180,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.mockGateway, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                    const Spacer(),
                    const Icon(Icons.contactless, color: Colors.white70),
                  ],
                ),
                const Spacer(),
                Text(
                  _cardCtrl.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(_nameCtrl.text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    Text(_expCtrl.text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('${s.total}: ${Money.format(widget.args.amountCentimes)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: s.cardHolder, border: const OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cardCtrl,
            decoration: InputDecoration(labelText: s.cardNumber, border: const OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expCtrl,
                  decoration: InputDecoration(labelText: s.expiry, border: const OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvvCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_processing)
            const Center(child: CircularProgressIndicator())
          else
            FilledButton(
              onPressed: _pay,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: Text(s.payNow, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}
