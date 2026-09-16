import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/data_store.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('الزبائن')),
      body: ValueListenableBuilder<List<Customer>>(
        valueListenable: store.customers,
        builder: (context, customers, _) {
          if (customers.isEmpty) {
            return const Center(child: Text('لا يوجد زبائن بعد. اضغط + للإضافة.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: customers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = customers[i];
              return Card(
                child: ListTile(
                  title: Text(c.name, textAlign: TextAlign.right),
                  subtitle: Text(
                    [if (c.activity.isNotEmpty) c.activity, if (c.phone.isNotEmpty) c.phone].join(' • '),
                    textAlign: TextAlign.right,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context, c),
                  ),
                  onTap: () => _openEditor(context, existing: c),
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

  void _openEditor(BuildContext context, {Customer? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _CustomerEditor(existing: existing)),
    );
  }

  void _confirmDelete(BuildContext context, Customer c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الزبون "${c.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DataStore.instance.removeCustomer(c);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CustomerEditor extends StatefulWidget {
  final Customer? existing;
  const _CustomerEditor({this.existing});

  @override
  State<_CustomerEditor> createState() => _CustomerEditorState();
}

class _CustomerEditorState extends State<_CustomerEditor> {
  late final TextEditingController _name;
  late final TextEditingController _activity;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _cr;
  late final TextEditingController _taxId;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _activity = TextEditingController(text: e?.activity ?? '');
    _address = TextEditingController(text: e?.address ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _cr = TextEditingController(text: e?.commercialRegister ?? '');
    _taxId = TextEditingController(text: e?.taxId ?? '');
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الزبون.')),
      );
      return;
    }

    if (widget.existing != null) {
      final c = widget.existing!;
      c.name = _name.text.trim();
      c.activity = _activity.text.trim();
      c.address = _address.text.trim();
      c.phone = _phone.text.trim();
      c.commercialRegister = _cr.text.trim();
      c.taxId = _taxId.text.trim();
      await DataStore.instance.updateCustomer();
    } else {
      await DataStore.instance.addCustomer(Customer(
        name: _name.text.trim(),
        activity: _activity.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        commercialRegister: _cr.text.trim(),
        taxId: _taxId.text.trim(),
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing != null ? 'تعديل زبون' : 'إضافة زبون')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, 'اسم الزبون'),
          _field(_activity, 'النشاط'),
          _field(_address, 'العنوان'),
          _field(_phone, 'الهاتف', keyboardType: TextInputType.phone),
          _field(_cr, 'رقم السجل التجاري'),
          _field(_taxId, 'الرقم الجبائي'),
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
