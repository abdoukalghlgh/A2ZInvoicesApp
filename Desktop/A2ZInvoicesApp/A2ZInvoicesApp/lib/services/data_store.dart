import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/customer.dart';
import '../models/supplier.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/company_info.dart';

/// مخزن بيانات بسيط يعتمد على ملفات JSON محفوظة في مجلد بيانات التطبيق
/// الخاص بالمستخدم على الجهاز. لا حاجة لأي خادم أو قاعدة بيانات خارجية.
class DataStore extends ChangeNotifier {
  DataStore._();
  static final DataStore instance = DataStore._();

  final ValueNotifier<List<Customer>> customers = ValueNotifier([]);
  final ValueNotifier<List<Supplier>> suppliers = ValueNotifier([]);
  final ValueNotifier<List<Product>> products = ValueNotifier([]);
  final ValueNotifier<List<Invoice>> invoices = ValueNotifier([]);
  CompanyInfo company = CompanyInfo();

  Directory? _dir;
  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<Directory> _rootDir() async {
    if (_dir != null) return _dir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/NourInvoicing');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _dir = dir;
    return dir;
  }

  File _fileFor(Directory dir, String name) => File('${dir.path}/$name');

  Future<void> load() async {
    final dir = await _rootDir();

    customers.value = await _loadList(
        _fileFor(dir, 'customers.json'), Customer.fromJson);
    suppliers.value = await _loadList(
        _fileFor(dir, 'suppliers.json'), Supplier.fromJson);
    products.value =
        await _loadList(_fileFor(dir, 'products.json'), Product.fromJson);
    invoices.value =
        await _loadList(_fileFor(dir, 'invoices.json'), Invoice.fromJson);

    final companyFile = _fileFor(dir, 'company.json');
    if (await companyFile.exists()) {
      try {
        final text = await companyFile.readAsString();
        company = CompanyInfo.fromJson(
            jsonDecode(text) as Map<String, dynamic>);
      } catch (_) {
        company = CompanyInfo();
      }
    }

    _loaded = true;
    notifyListeners();
  }

  Future<List<T>> _loadList<T>(
      File file, T Function(Map<String, dynamic>) fromJson) async {
    try {
      if (await file.exists()) {
        final text = await file.readAsString();
        final list = jsonDecode(text) as List<dynamic>;
        return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // في حال تلف الملف، نبدأ بقائمة فارغة بدل تعطل التطبيق
    }
    return [];
  }

  Future<void> _saveList(
      String name, List<dynamic> list, Map<String, dynamic> Function(dynamic) toJson) async {
    final dir = await _rootDir();
    final file = _fileFor(dir, name);
    final data = list.map(toJson).toList();
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data));
  }

  Future<void> saveCustomers() async {
    await _saveList('customers.json', customers.value, (c) => (c as Customer).toJson());
    notifyListeners();
  }

  Future<void> saveSuppliers() async {
    await _saveList('suppliers.json', suppliers.value, (s) => (s as Supplier).toJson());
    notifyListeners();
  }

  Future<void> saveProducts() async {
    await _saveList('products.json', products.value, (p) => (p as Product).toJson());
    notifyListeners();
  }

  Future<void> saveInvoices() async {
    await _saveList('invoices.json', invoices.value, (i) => (i as Invoice).toJson());
    notifyListeners();
  }

  Future<void> saveCompany() async {
    final dir = await _rootDir();
    final file = _fileFor(dir, 'company.json');
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(company.toJson()));
    notifyListeners();
  }

  /// يولّد رقم فاتورة تلقائي بصيغة "السنة/التسلسل" مثل 2026/001
  String getNextInvoiceNumber() {
    final year = DateTime.now().year;
    final count = invoices.value.where((i) => i.date.year == year).length;
    final next = count + 1;
    return '$year/${next.toString().padLeft(3, '0')}';
  }

  // ---- عمليات مساعدة على القوائم (تُحدّث الواجهة وتحفظ تلقائيًا) ----

  Future<void> addCustomer(Customer c) async {
    customers.value = [...customers.value, c];
    await saveCustomers();
  }

  Future<void> updateCustomer() async {
    customers.value = [...customers.value];
    await saveCustomers();
  }

  Future<void> removeCustomer(Customer c) async {
    customers.value = customers.value.where((e) => e.id != c.id).toList();
    await saveCustomers();
  }

  Future<void> addSupplier(Supplier s) async {
    suppliers.value = [...suppliers.value, s];
    await saveSuppliers();
  }

  Future<void> updateSupplier() async {
    suppliers.value = [...suppliers.value];
    await saveSuppliers();
  }

  Future<void> removeSupplier(Supplier s) async {
    suppliers.value = suppliers.value.where((e) => e.id != s.id).toList();
    await saveSuppliers();
  }

  Future<void> addProduct(Product p) async {
    products.value = [...products.value, p];
    await saveProducts();
  }

  Future<void> updateProduct() async {
    products.value = [...products.value];
    await saveProducts();
  }

  Future<void> removeProduct(Product p) async {
    products.value = products.value.where((e) => e.id != p.id).toList();
    await saveProducts();
  }

  Future<void> addInvoice(Invoice i) async {
    invoices.value = [...invoices.value, i];
    await saveInvoices();
  }

  Future<void> removeInvoice(Invoice i) async {
    invoices.value = invoices.value.where((e) => e.id != i.id).toList();
    await saveInvoices();
  }
}
