import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../view_models/payment_method_view_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../core/dialogs.dart';

class AddEditPaymentMethodScreen extends StatefulWidget {
  final String userId;
  final PaymentMethodModel? method;

  const AddEditPaymentMethodScreen({
    super.key,
    required this.userId,
    this.method,
  });

  @override
  State<AddEditPaymentMethodScreen> createState() =>
      _AddEditPaymentMethodScreenState();
}

class _AddEditPaymentMethodScreenState
    extends State<AddEditPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  late final PaymentMethodViewModel _viewModel;

  PaymentMethodType _selectedType = PaymentMethodType.cash;
  bool _isActive = true;

  bool get isEditMode => widget.method != null;

  @override
  void initState() {
    super.initState();
    _viewModel = PaymentMethodViewModel(
      repository: PaymentMethodRepository(
        service: PaymentMethodService(),
      ),
      userId: widget.userId,
    );

    // Load existing data if editing
    if (isEditMode) {
      final method = widget.method!;
      _nameController.text = method.name;
      _selectedType = method.type;
      _bankNameController.text = method.bankName ?? '';
      _accountNumberController.text = method.accountNumber ?? '';
      _isActive = method.isActive;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final method = PaymentMethodModel(
      id: widget.method?.id ?? const Uuid().v4(),
      userId: widget.userId,
      name: _nameController.text.trim(),
      type: _selectedType,
      bankName: _selectedType == PaymentMethodType.bank
          ? _bankNameController.text.trim()
          : null,
      accountNumber: _accountNumberController.text.trim().isNotEmpty
          ? _accountNumberController.text.trim()
          : null,
      isActive: _isActive,
      order: widget.method?.order ?? 0,
      createdAt: widget.method?.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      if (isEditMode) {
        await _viewModel.updatePaymentMethod(widget.method!.id, method);
      } else {
        await _viewModel.createPaymentMethod(method);
      }

      if (mounted) {
        await showSuccessDialog(
          context,
          title: isEditMode ? 'Berhasil Diperbarui' : 'Berhasil Ditambahkan',
          message: isEditMode
              ? 'Metode pembayaran berhasil diperbarui.'
              : 'Metode pembayaran berhasil ditambahkan.',
          icon: isEditMode ? Icons.edit_note : Icons.check_circle,
        );
        if (mounted) {
          Navigator.of(context).pop(
            isEditMode
                ? 'Metode pembayaran berhasil diperbarui'
                : 'Metode pembayaran berhasil ditambahkan',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await showErrorDialog(
          context,
          title: 'Gagal Menyimpan',
          message: _viewModel.errorMessage ?? e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Metode Pembayaran' : 'Tambah Metode Pembayaran',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Metode Pembayaran',
                hintText: 'Contoh: Bank BCA, Dana, Tunai',
                prefixIcon: Icon(Icons.label_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama metode pembayaran tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Type dropdown
            DropdownButtonFormField<PaymentMethodType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipe',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: PaymentMethodType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Text(type.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Bank name (conditional)
            if (_selectedType == PaymentMethodType.bank) ...[
              TextFormField(
                controller: _bankNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Bank',
                  hintText: 'Contoh: Bank Mandiri, BCA',
                  prefixIcon: Icon(Icons.account_balance),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_selectedType == PaymentMethodType.bank &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Nama bank harus diisi untuk tipe Bank';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Account number (optional)
            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekening/Akun (Opsional)',
                hintText: 'Hanya untuk referensi pribadi',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
                helperText: 'Opsional, tidak wajib diisi',
              ),
            ),
            const SizedBox(height: 16),

            // Active status
            SwitchListTile(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              title: const Text('Status Aktif'),
              subtitle: Text(
                _isActive
                    ? 'Metode ini dapat digunakan untuk transaksi'
                    : 'Metode ini tidak akan muncul di pilihan transaksi',
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return FilledButton(
                  onPressed: _viewModel.isLoading ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditMode ? 'Perbarui' : 'Simpan',
                          style: const TextStyle(fontSize: 16),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
