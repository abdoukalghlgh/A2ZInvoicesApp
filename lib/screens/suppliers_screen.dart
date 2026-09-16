import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/data_store.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('الممونون')),
      body: ValueListenableBuilder<List<Supplier>>(
        valueListenable: store.suppliers,
        builder: (context, suppliers, _) {
          if (suppliers.isEmpty) {
            return const Center(child: Text('لا يوجد ممونون بعد. اضغط + للإضافة.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: suppliers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = suppliers[i];
              return Card(
                child: ListTile(
                  title: Text(s.name, textAlign: TextAlign.right),
                  subtitle: Text(
                    [if (s.activity.isNotEmpty) s.activity, if (s.phone.isNotEmpty) s.phone].join(' • '),
                    textAlign: TextAlign.right,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context, s),
                  ),
                  onTap: () => _openEditor(context, existing: s),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEditor(BuildContext context, {Supplier? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _SupplierEditor(existing: existing)),
    );
  }

  void _confirmDelete(BuildContext context, Supplier s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الممون "${s.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DataStore.instance.removeSupplier(s);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SupplierEditor extends StatefulWidget {
  final Supplier? existing;
  const _SupplierEditor({this.existing});

  @override
  State<_SupplierEditor> createState() => _SupplierEditorState();
}

class _SupplierEditorState extends State<_SupplierEditor> {
  late final TextEditingController _name;
  late final TextEditingController _activity;
  late final TextEditingController _address;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _activity = TextEditingController(text: e?.activity ?? '');
    _address = TextEditingController(text: e?.address ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الممون.')),
      );
      return;
    }

    if (widget.existing != null) {
      final s = widget.existing!;
      s.name = _name.text.trim();
      s.activity = _activity.text.trim();
      s.address = _address.text.trim();
      s.phone = _phone.text.trim();
      await DataStore.instance.updateSupplier();
    } else {
      await DataStore.instance.addSupplier(Supplier(
        name: _name.text.trim(),
        activity: _activity.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing != null ? 'تعديل ممون' : 'إضافة ممون')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, 'اسم الممون'),
          _field(_activity, 'النشاط'),
          _field(_address, 'العنوان'),
          _field(_phone, 'الهاتف', keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('حفظ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
