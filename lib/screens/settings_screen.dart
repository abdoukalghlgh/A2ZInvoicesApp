import 'package:flutter/material.dart';
import '../services/data_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _name;
  late final TextEditingController _activity;
  late final TextEditingController _address;
  late final TextEditingController _cr;
  late final TextEditingController _taxId;
  late final TextEditingController _articleNumber;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final c = DataStore.instance.company;
    _name = TextEditingController(text: c.name);
    _activity = TextEditingController(text: c.activity);
    _address = TextEditingController(text: c.address);
    _cr = TextEditingController(text: c.commercialRegister);
    _taxId = TextEditingController(text: c.taxId);
    _articleNumber = TextEditingController(text: c.articleNumber);
    _phone = TextEditingController(text: c.phone);
  }

  Future<void> _save() async {
    final c = DataStore.instance.company;
    c.name = _name.text.trim();
    c.activity = _activity.text.trim();
    c.address = _address.text.trim();
    c.commercialRegister = _cr.text.trim();
    c.taxId = _taxId.text.trim();
    c.articleNumber = _articleNumber.text.trim();
    c.phone = _phone.text.trim();
    await DataStore.instance.saveCompany();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ معلومات الشركة بنجاح.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('معلومات الشركة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, 'اسم الشركة / الممون'),
          _field(_activity, 'النشاط'),
          _field(_address, 'العنوان'),
          _field(_cr, 'رقم السجل التجاري'),
          _field(_taxId, 'الرقم الجبائي'),
          _field(_articleNumber, 'رقم المادة'),
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
