import 'package:juix_na/features/production/model/production_models.dart';

/// State for the Stocking Hub screen.
class StockingHubState {
  final List<ActivityItem> recentActivity;
  final bool isLoading;
  final String? error;

  const StockingHubState({
    required this.recentActivity,
    required this.isLoading,
    this.error,
  });

  /// Initial state.
  factory StockingHubState.initial() {
    return const StockingHubState(
      recentActivity: [],
      isLoading: false,
      error: null,
    );
  }

  /// Check if state has activity data.
  bool get hasData => recentActivity.isNotEmpty;

  /// Check if state has an error.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Create a copy with updated values.
  StockingHubState copyWith({
    List<ActivityItem>? recentActivity,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return StockingHubState(
      recentActivity: recentActivity ?? this.recentActivity,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
