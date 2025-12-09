import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/product/data/models/product_model.dart';

class ExportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Xuất danh sách sản phẩm
  static Future<void> exportProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      // Xuất Excel (.xlsx)
      final excel = Excel.createExcel();
      final String sheetName = 'SanPham';
      excel.rename('Sheet1', sheetName);
      final Sheet sheet = excel[sheetName];

      // Header
      sheet.appendRow(<CellValue?>[
        TextCellValue('Tên sản phẩm'),
        TextCellValue('Thương hiệu'),
        TextCellValue('Danh mục'),
        TextCellValue('Giá'),
        TextCellValue('Gốc'),
        TextCellValue('Giảm giá'),
        TextCellValue('Tồn kho'),
        TextCellValue('Đã bán'),
        TextCellValue('Đánh giá'),
        TextCellValue('Số đánh giá'),
        TextCellValue('Trạng thái'),
        TextCellValue('Ngày tạo'),
      ]);

      // Data rows
      for (final product in products) {
        sheet.appendRow(<CellValue?>[
          TextCellValue(product.name),
          TextCellValue(product.brand),
          TextCellValue(product.category),
          DoubleCellValue(product.price),
          DoubleCellValue(product.originalPrice),
          DoubleCellValue(product.discount),
          IntCellValue(product.stock),
          IntCellValue(product.sold),
          DoubleCellValue(product.rating),
          IntCellValue(product.reviewCount),
          TextCellValue(product.isActive ? 'Hoạt động' : 'Ẩn'),
          TextCellValue(product.createdAt.toString().split(' ').first),
        ]);
      }

      final List<int>? bytes = excel.encode();
      if (bytes == null) {
        throw Exception('Không thể tạo file Excel');
      }
      await _saveBytesToDevice(Uint8List.fromList(bytes), 'san_pham.xlsx');
    } catch (e) {
      throw Exception('Lỗi xuất sản phẩm: $e');
    }
  }

  // Lưu file nhị phân (Excel) vào thiết bị (ưu tiên thư mục Download nếu có)
  static Future<void> _saveBytesToDevice(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      Directory? targetDir;

      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) {
        targetDir = downloads;
      } else {
        targetDir = await getExternalStorageDirectory();
        targetDir ??= await getApplicationDocumentsDirectory();
      }

      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception('Lỗi lưu file: $e');
    }
  }
}
