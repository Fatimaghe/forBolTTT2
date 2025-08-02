class StockTransfer {
  final String id;
  final String reference;
  final String sourceLocationId;
  final String sourceLocationName;
  final String destinationLocationId;
  final String destinationLocationName;
  final DateTime scheduledDate;
  final String status;
  final String responsiblePerson;
  final List<StockTransferLine> lines;
  final String notes;
  final DateTime createdAt;

  StockTransfer({
    required this.id,
    required this.reference,
    required this.sourceLocationId,
    required this.sourceLocationName,
    required this.destinationLocationId,
    required this.destinationLocationName,
    required this.scheduledDate,
    required this.status,
    required this.responsiblePerson,
    required this.lines,
    required this.notes,
    required this.createdAt,
  });

  factory StockTransfer.fromJson(Map<String, dynamic> json) {
    return StockTransfer(
      id: json['id'],
      reference: json['reference'],
      sourceLocationId: json['source_location_id'],
      sourceLocationName: json['source_location_name'],
      destinationLocationId: json['destination_location_id'],
      destinationLocationName: json['destination_location_name'],
      scheduledDate: DateTime.parse(json['scheduled_date']),
      status: json['status'],
      responsiblePerson: json['responsible_person'],
      lines: (json['lines'] as List).map((line) => StockTransferLine.fromJson(line)).toList(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'source_location_id': sourceLocationId,
      'source_location_name': sourceLocationName,
      'destination_location_id': destinationLocationId,
      'destination_location_name': destinationLocationName,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': status,
      'responsible_person': responsiblePerson,
      'lines': lines.map((line) => line.toJson()).toList(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class StockTransferLine {
  final String id;
  final String productId;
  final String productName;
  final double quantityDemand;
  final double quantityDone;
  final String unit;
  final double demandQuantity;
  final double doneQuantity;

  StockTransferLine({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantityDemand,
    required this.quantityDone,
    required this.unit,
    required this.demandQuantity,
    required this.doneQuantity,
  });

  factory StockTransferLine.fromJson(Map<String, dynamic> json) {
    return StockTransferLine(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantityDemand: json['quantity_demand'].toDouble(),
      quantityDone: json['quantity_done'].toDouble(),
      unit: json['unit'],
      demandQuantity: json['demand_quantity'].toDouble(),
      doneQuantity: json['done_quantity'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity_demand': quantityDemand,
      'quantity_done': quantityDone,
      'unit': unit,
      'demand_quantity': demandQuantity,
      'done_quantity': doneQuantity,
    };
  }
}