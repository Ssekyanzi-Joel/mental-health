// lib/pages/payment_options_page.dart
import 'package:flutter/material.dart';
import 'payment_form_page.dart';

class PaymentOption {
  final String id;
  final String label;
  final String asset;

  PaymentOption({required this.id, required this.label, required this.asset});
}

class PaymentOptionsPage extends StatelessWidget {
  const PaymentOptionsPage({super.key});

  static final List<PaymentOption> _options = [
    PaymentOption(id: 'mtn', label: 'MTN', asset: 'assets/images/mtn.png'),
    PaymentOption(id: 'airtel', label: 'Airtel', asset: 'assets/images/airtel.png'),
    PaymentOption(id: 'visa', label: 'Visa', asset: 'assets/images/visa.png'),
    PaymentOption(id: 'mastercard', label: 'Mastercard', asset: 'assets/images/mastercard.png'),
    PaymentOption(id: 'mtn_congo', label: 'MTN Congo', asset: 'assets/images/mtn_congo.png'),
    PaymentOption(id: 'safaricom', label: 'Safaricom', asset: 'assets/images/safaricom.png'),
    PaymentOption(id: 'bank', label: 'Bank Transfer', asset: 'assets/images/bank.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: _options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // two per row
            childAspectRatio: 4 / 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, i) {
            final opt = _options[i];
            return InkWell(
              onTap: () {
                // navigate to form, passing the selected method
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentFormPage(methodId: opt.id, methodLabel: opt.label, asset: opt.asset),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(opt.asset, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 8),
                      Text(opt.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
