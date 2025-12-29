import 'package:juix_na/features/production/model/production_models.dart';

/// State for the Purchase Entry screen.
class PurchaseEntryState {
  final int? supplierId;
  final DateTime date;
  final String? refInvoice;
  final List<PurchaseItem> items;
  final bool markAsReceived;
  final bool isLoading;
  final String? error;

  const PurchaseEntryState({
    this.supplierId,
    required this.date,
    this.refInvoice,
    required this.items,
    required this.markAsReceived,
    required this.isLoading,
    this.error,
  });

  /// Initial state.
  factory PurchaseEntryState.initial() {
    return PurchaseEntryState(
      supplierId: null,
      date: DateTime.now(),
      refInvoice: null,
      items: [],
      markAsReceived: false,
      isLoading: false,
      error: null,
    );
  }

  /// Calculate total cost from all items.
  double calculateTotal() {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Calculate total quantity.
  double calculateTotalQuantity() {
    return items.fold(0.0, (sum, item) => sum + item.quantity);
  }

  /// Get total items count.
  int getTotalItemsCount() {
    return items.length;
  }

  /// Add an item to the purchase entry.
  PurchaseEntryState addItem(PurchaseItem item) {
    return copyWith(items: [...items, item]);
  }

  /// Remove an item by index.
  PurchaseEntryState removeItem(int index) {
    if (index < 0 || index >= items.length) return this;
    final newItems = List<PurchaseItem>.from(items);
    newItems.removeAt(index);
    return copyWith(items: newItems);
  }

  /// Update an item at a specific index.
  PurchaseEntryState updateItem(int index, PurchaseItem item) {
    if (index < 0 || index >= items.length) return this;
    final newItems = List<PurchaseItem>.from(items);
    newItems[index] = item;
    return copyWith(items: newItems);
  }

  /// Check if the form is valid.
  /// Validates that supplier is selected, date is set, and items are present.
  /// Note: Individual item validation (quantities, costs) is handled by the
  /// PurchaseEntry domain model's isValid() method.
  bool isValid() {
    return supplierId != null && supplierId! > 0 && items.isNotEmpty;
    // Date is always required (non-nullable), so no need to check
  }

  /// Create a PurchaseEntry domain model from this state.
  PurchaseEntry toPurchaseEntry() {
    return PurchaseEntry(
      supplierId: supplierId!,
      date: date,
      refInvoice: refInvoice,
      items: items,
      markAsReceived: markAsReceived,
    );
  }

  /// Create a copy with updated values.
  PurchaseEntryState copyWith({
    int? supplierId,
    DateTime? date,
    String? refInvoice,
    List<PurchaseItem>? items,
    bool? markAsReceived,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PurchaseEntryState(
      supplierId: supplierId ?? this.supplierId,
      date: date ?? this.date,
      refInvoice: refInvoice ?? this.refInvoice,
      items: items ?? this.items,
      markAsReceived: markAsReceived ?? this.markAsReceived,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Reset state to initial values.
  PurchaseEntryState reset() {
    return PurchaseEntryState.initial();
  }
}
