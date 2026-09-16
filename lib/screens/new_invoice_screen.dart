import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_line.dart';
import '../services/data_store.dart';
import 'invoice_preview_screen.dart';

const _paymentMethods = ['نقدا', 'شيك', 'تحويل بنكي', 'أجل'];

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _store = DataStore.instance;

  late final TextEditingController _numberCtrl;
  DateTime _date = DateTime.now();

  Customer? _selectedCustomer;
  final _customerName = TextEditingController();
  final _customerActivity = TextEditingController();
  final _customerAddress = TextEditingController();
  final _customerCR = TextEditingController();
  final _customerTaxId = TextEditingController();

  final List<InvoiceLine> _lines = [];

  final _vatRateCtrl = TextEditingController(text: '17');
  final _fiscalStampCtrl = TextEditingController(text: '0');
  String _paymentMethod = _paymentMethods.first;

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController(text: _store.getNextInvoiceNumber());
  }

  double get _subTotal {
    var sum = 0.0;
    for (final l in _lines) {
      sum += l.total;
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  double get _vatRate => double.tryParse(_vatRateCtrl.text.trim()) ?? 0;
  double get _fiscalStamp => double.tryParse(_fiscalStampCtrl.text.trim()) ?? 0;
  double get _vatAmount => double.parse((_subTotal * _vatRate / 100).toStringAsFixed(2));
  double get _grandTotal => double.parse((_subTotal + _vatAmount + _fiscalStamp).toStringAsFixed(2));

  void _pickCustomer() async {
    final customers = _store.customers.value;
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد زبائن محفوظون بعد. يمكنك إدخال بياناته يدويًا أدناه.')),
      );
      return;
    }
    final chosen = await showModalBottomSheet<Customer>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: customers
              .map((c) => ListTile(
                    title: Text(c.name, textAlign: TextAlign.right),
                    subtitle: Text(c.activity, textAlign: TextAlign.right),
                    onTap: () => Navigator.pop(ctx, c),
                  ))
              .toList(),
        ),
      ),
    );
    if (chosen != null) {
      setState(() {
        _selectedCustomer = chosen;
        _customerName.text = chosen.name;
        _customerActivity.text = chosen.activity;
        _customerAddress.text = chosen.address;
        _customerCR.text = chosen.commercialRegister;
        _customerTaxId.text = chosen.taxId;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _addFromStock() async {
    final products = _store.products.value;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد سلع محفوظة بعد. أضف سلعة يدوية بدلًا من ذلك.')),
      );
      return;
    }
    final chosen = await showModalBottomSheet<Product>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: products
              .map((p) => ListTile(
                    title: Text(p.name, textAlign: TextAlign.right),
                    subtitle: Text('${p.unitPrice.toStringAsFixed(2)} د.ج / ${p.unit}', textAlign: TextAlign.right),
                    onTap: () => Navigator.pop(ctx, p),
                  ))
              .toList(),
        ),
      ),
    );
    if (chosen != null) {
      setState(() {
        _lines.add(InvoiceLine(
          productId: chosen.id,
          productName: chosen.name,
          unit: chosen.unit,
          quantity: 1,
          unitPrice: chosen.unitPrice,
        ));
      });
    }
  }

  void _addManualLine() {
    setState(() {
      _lines.add(InvoiceLine(productName: 'سلعة جديدة', unit: 'قطعة', quantity: 1, unitPrice: 0));
    });
    _editLine(_lines.length - 1);
  }

  void _editLine(int index) async {
    final line = _lines[index];
    final nameCtrl = TextEditingController(text: line.productName);
    final unitCtrl = TextEditingController(text: line.unit);
    final qtyCtrl = TextEditingController(text: _trim(line.quantity));
    final priceCtrl = TextEditingController(text: _trim(line.unitPrice));

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('تعديل سطر', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(controller: nameCtrl, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'التعيين')),
            const SizedBox(height: 10),
            TextField(controller: unitCtrl, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'الوحدة')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'الكمية'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'سعر الوحدة'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx, false),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('حذف السطر', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('تم'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        line.productName = nameCtrl.text.trim();
        line.unit = unitCtrl.text.trim();
        line.quantity = double.tryParse(qtyCtrl.text.trim()) ?? 0;
        line.unitPrice = double.tryParse(priceCtrl.text.trim()) ?? 0;
      });
    } else if (result == false) {
      setState(() => _lines.removeAt(index));
    }
  }

  static String _trim(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  bool _validate() {
    if (_customerName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم الزبون أو اختياره من القائمة.')),
      );
      return false;
    }
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة سطر واحد على الأقل إلى الفاتورة.')),
      );
      return false;
    }
    return true;
  }

  Invoice _buildInvoice() {
    return Invoice(
      number: _numberCtrl.text.trim().isEmpty ? _store.getNextInvoiceNumber() : _numberCtrl.text.trim(),
      date: _date,
      customerId: _selectedCustomer?.id ?? '',
      customerName: _customerName.text.trim(),
      customerActivity: _customerActivity.text.trim(),
      customerAddress: _customerAddress.text.trim(),
      customerCommercialRegister: _customerCR.text.trim(),
      customerTaxId: _customerTaxId.text.trim(),
      vatRate: _vatRate,
      fiscalStamp: _fiscalStamp,
      paymentMethod: _paymentMethod,
      lines: _lines
          .map((l) => InvoiceLine(
                productId: l.productId,
                productName: l.productName,
                unit: l.unit,
                quantity: l.quantity,
                unitPrice: l.unitPrice,
              ))
          .toList(),
    );
  }

  Future<void> _save() async {
    if (!_validate()) return;
    await _store.addInvoice(_buildInvoice());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الفاتورة بنجاح.')));
      Navigator.of(context).pop();
    }
  }

  void _preview() {
    if (!_validate()) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoice: _buildInvoice())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فاتورة جديدة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _numberCtrl,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(labelText: 'رقم الفاتورة'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'التاريخ'),
                    child: Text(DateFormat('dd/MM/yyyy').format(_date), textAlign: TextAlign.right),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('بيانات الزبون', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _pickCustomer,
                icon: const Icon(Icons.person_search),
                label: const Text('اختيار من القائمة'),
              ),
            ],
          ),
          _field(_customerName, 'اسم الزبون'),
          _field(_customerActivity, 'النشاط'),
          _field(_customerAddress, 'العنوان'),
          _field(_customerCR, 'رقم السجل التجاري'),
          _field(_customerTaxId, 'الرقم الجبائي'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('سطور الفاتورة', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _addFromStock,
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: const Text('من المخزون'),
                  ),
                  TextButton.icon(
                    onPressed: _addManualLine,
                    icon: const Icon(Icons.add),
                    label: const Text('يدويًا'),
                  ),
                ],
              ),
            ],
          ),
          if (_lines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('لا توجد سطور بعد.', textAlign: TextAlign.center),
            )
          else
            ..._lines.asMap().entries.map((entry) {
              final i = entry.key;
              final l = entry.value;
              return Card(
                child: ListTile(
                  title: Text(l.productName, textAlign: TextAlign.right),
                  subtitle: Text(
                    '${_trim(l.quantity)} ${l.unit} × ${l.unitPrice.toStringAsFixed(2)} = ${l.total.toStringAsFixed(2)} د.ج',
                    textAlign: TextAlign.right,
                  ),
                  onTap: () => _editLine(i),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => setState(() => _lines.removeAt(i)),
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _vatRateCtrl,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'نسبة القيمة المضافة %'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _fiscalStampCtrl,
                  textAlign: TextAlign.right,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'الطابع الجبائي'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            decoration: const InputDecoration(labelText: 'كيفية التسديد'),
            items: _paymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _paymentMethod = v ?? _paymentMethod),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFEBF2F9),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _totalRow('المجموع بدون رسوم', _subTotal),
                  _totalRow('قيمة الرسم', _vatAmount),
                  _totalRow('المجموع الكلي', _grandTotal, bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _preview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('معاينة / طباعة'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ الفاتورة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        textAlign: TextAlign.right,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, fontSize: bold ? 16 : 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${value.toStringAsFixed(2)} د.ج', style: style),
          Text(label, style: style),
        ],
      ),
    );
  }
}
