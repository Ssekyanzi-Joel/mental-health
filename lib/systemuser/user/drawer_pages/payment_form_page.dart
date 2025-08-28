import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PaymentFormPage extends StatefulWidget {
  final String methodId;
  final String methodLabel;
  final String asset;

  const PaymentFormPage({
    super.key,
    required this.methodId,
    required this.methodLabel,
    required this.asset,
  });

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  File? _screenshot;
  bool _loading = false;

  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> _pickScreenshot() async {
    final res = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (res != null) setState(() => _screenshot = File(res.path));
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to pay.')));
      return;
    }

    setState(() => _loading = true);
    String screenshotUrl = '';

    try {
      if (_screenshot != null) {
        final path = 'payments/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _storage.ref().child(path);
        await ref.putFile(_screenshot!);
        screenshotUrl = await ref.getDownloadURL();
      }

      final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

      await _fire.collection('payments').add({
        'userId': user.uid,
        'userName': _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : (user.displayName ?? ''),
        'method': widget.methodLabel,
        'methodId': widget.methodId,
        'amount': amount,
        'phone': _phoneCtrl.text.trim(),
        'reference': _refCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'screenshotUrl': screenshotUrl,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtReadable': DateFormat.yMMMd().add_jm().format(DateTime.now()),
        'confirmedBy': null,
        'confirmedAt': null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted. Awaiting confirmation.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final method = widget.methodLabel;
    return Scaffold(
      appBar: AppBar(
        title: Text("Pay with $method"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // ✅ Fix layout issues
                  children: [
                    Center(child: Image.asset(widget.asset, height: 80)),
                    const SizedBox(height: 8),
                    Text(
                      'Fill payment details to confirm your $method payment',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount', prefixText: 'UGX '),
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Payer Name'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone' : null,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _refCtrl,
                      decoration: const InputDecoration(labelText: 'Transaction Reference'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter transaction reference' : null,
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    ),

                    const SizedBox(height: 12),

                    if (_screenshot != null)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_screenshot!, height: 160, fit: BoxFit.cover),
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() => _screenshot = null),
                            icon: const Icon(Icons.delete),
                            label: const Text('Remove screenshot'),
                          ),
                        ],
                      ),

                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _pickScreenshot,
                          icon: const Icon(Icons.photo),
                          label: const Text('Upload screenshot (optional)'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _loading ? null : _submitPayment,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Confirm Payment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
