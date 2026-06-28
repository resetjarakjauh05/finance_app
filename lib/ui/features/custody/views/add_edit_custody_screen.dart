import 'package:flutter/material.dart';
import '../../../../data/services/custody_service.dart';
import '../../../../data/repositories/custody_repository.dart';
import '../../../../domain/models/custody_model.dart';
import '../../../core/dialogs.dart';
import '../view_models/custody_view_model.dart';

class AddEditCustodyScreen extends StatefulWidget {
  final String userId;
  final CustodyModel? custody;

  const AddEditCustodyScreen({super.key, required this.userId, this.custody});

  @override
  State<AddEditCustodyScreen> createState() => _AddEditCustodyScreenState();
}

class _AddEditCustodyScreenState extends State<AddEditCustodyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  late final CustodyViewModel _viewModel;

  CustodyType _selectedType = CustodyType.diterima;

  bool get isEditMode => widget.custody != null;

  @override
  void initState() {
    super.initState();
    _viewModel = CustodyViewModel(
      repository: CustodyRepository(service: CustodyService()),
      userId: widget.userId,
    );
    if (isEditMode) {
      final c = widget.custody!;
      _nameController.text = c.depositorName;
      _descController.text = c.description ?? '';
      _selectedType = c.type;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      if (isEditMode) {
        final updated = widget.custody!.copyWith(
          depositorName: _nameController.text.trim(),
          type: _selectedType,
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          updatedAt: DateTime.now(),
        );
        await _viewModel.updateCustody(updated);
      } else {
        await _viewModel.createCustody(
          depositorName: _nameController.text.trim(),
          totalNominal: 0, // dihitung dari movements
          type: _selectedType,
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
        );
      }
      if (mounted) {
        await showSuccessDialog(
          context,
          title: isEditMode ? 'Berhasil Diperbarui' : 'Berhasil Ditambahkan',
          message: isEditMode
              ? 'Titipan berhasil diperbarui.'
              : 'Titipan berhasil ditambahkan.',
          icon: Icons.check_circle,
        );
        if (mounted) {
          Navigator.of(context).pop(
            isEditMode ? 'Titipan berhasil diperbarui' : 'Titipan berhasil ditambahkan',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        await showErrorDialog(context,
            title: 'Gagal Menyimpan',
            message: _viewModel.errorMessage ?? e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Titipan' : 'Tambah Titipan'),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton(
              onPressed: _viewModel.isLoading ? null : _handleSave,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _viewModel.isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(isEditMode ? 'Perbarui' : 'Simpan',
                      style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipe
            Text('Tipe Titipan',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            SegmentedButton<CustodyType>(
              segments: const [
                ButtonSegment(
                  value: CustodyType.diterima,
                  label: Text('Diterima'),
                  icon: Icon(Icons.arrow_downward, size: 16),
                ),
                ButtonSegment(
                  value: CustodyType.diberikan,
                  label: Text('Diberikan'),
                  icon: Icon(Icons.arrow_upward, size: 16),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (val) =>
                  setState(() => _selectedType = val.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama Penitip',
                prefixIcon: Icon(Icons.person_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Keterangan (opsional)',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
