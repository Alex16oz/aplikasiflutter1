// lib/models/sparepart_models.dart

class SparepartSummary {
  final int id;
  final String? partNumber;
  final String sparepartName;
  final String? location;
  final String? description;
  final int totalStock;
  final int minimumStockLevel;

  SparepartSummary({
    required this.id,
    this.partNumber,
    required this.sparepartName,
    this.location,
    this.description,
    required this.totalStock,
    required this.minimumStockLevel,
  });

  // FUNGSI INI SUDAH DIPERBAIKI UNTUK AMAN DARI NILAI NULL
  factory SparepartSummary.fromJson(Map<String, dynamic> json) {
    return SparepartSummary(
      id: json['id'] ?? -1,
      partNumber: json['part_number'],
      sparepartName: json['sparepart_name'] ?? 'Unknown Sparepart',
      location: json['location'],
      description: json['description'],

      // PERBAIKAN UTAMA: Mengubah null menjadi 0 untuk mencegah error
      totalStock: (json['total_stock'] as num?)?.toInt() ?? 0,
      minimumStockLevel: (json['minimum_stock_level'] as num?)?.toInt() ?? 0,
    );
  }
}

class StockTransaction {
  final int id;
  final int sparepartId;
  final String transactionType;
  final int quantity;
  final double? unitPrice;
  final DateTime? purchaseDate;
  final String? supplier;
  final DateTime transactionDate;

  StockTransaction({
    required this.id,
    required this.sparepartId,
    required this.transactionType,
    required this.quantity,
    this.unitPrice,
    this.purchaseDate,
    this.supplier,
    required this.transactionDate,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'],
      sparepartId: json['sparepart_id'],
      transactionType: json['transaction_type'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
      supplier: json['supplier'],
      transactionDate: DateTime.parse(json['transaction_date']),
    );
  }
}