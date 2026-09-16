import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/data_store.dart';

const _units = ['قطعة', 'كيس', 'رولو', 'متر', 'كلغ', 'لتر', 'علبة', 'صندوق'];

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DataStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('السلع والمخزون')),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: store.products,
        builder: (context, products, _) {
          if (products.isEmpty) {
            return const Center(child: Text('لا توجد سلع بعد. اضغط + للإضافة.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = products[i];
              return Card(
                child: ListTile(
                  title: Text(p.name, textAlign: TextAlign.right),
                  subtitle: Text(
                    'الوحدة: ${p.unit} • السعر: ${p.unitPrice.toStringAsFixed(2)} د.ج • المخزون: ${_trim(p.quantityInStock)}',
                    textAlign: TextAlign.right,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context, p),
                  ),
                  onTap: () => _openEditor(context, existing: p),
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

  static String _trim(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void _openEditor(BuildContext context, {Product? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _ProductEditor(existing: existing)),
    );
  }

  void _confirmDelete(BuildContext context, Product p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف السلعة "${p.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DataStore.instance.removeProduct(p);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProductEditor extends StatefulWidget {
  final Product? existing;
  const _ProductEditor({this.existing});

  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(text: e != null ? e.unitPrice.toString() : '');
    _stock = TextEditingController(text: e != null ? e.quantityInStock.toString() : '');
    _unit = e?.unit ?? _units.first;
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال تعيين السلعة.')),
      );
      return;
    }
    final price = double.tryParse(_price.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال سعر صحيح.')),
      );
      return;
    }
    final stock = double.tryParse(_stock.text.trim()) ?? 0;

    if (widget.existing != null) {
      final p = widget.existing!;
      p.name = _name.text.trim();
      p.unit = _unit;
      p.unitPrice = price;
      p.quantityInStock = stock;
      await DataStore.instance.updateProduct();
    } else {
      await DataStore.instance.addProduct(Product(
        name: _name.text.trim(),
        unit: _unit,
        unitPrice: price,
        quantityInStock: stock,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing != null ? 'تعديل سلعة' : 'إضافة سلعة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _name,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(labelText: 'التعيين (اسم السلعة)'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              value: _unit,
              decoration: const InputDecoration(labelText: 'وحدة القياس'),
              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              onChanged: (v) => setState(() => _unit = v ?? _unit),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _price,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'سعر الوحدة (د.ج)'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _stock,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'الكمية المتوفرة في المخزون'),
            ),
          ),
          const SizedBox(height: 8),
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
}
