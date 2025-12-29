import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juix_na/bootstrap.dart';
import 'package:juix_na/features/production/data/production_api.dart';
import 'package:juix_na/features/production/data/production_repository.dart';

/// Riverpod provider for ProductionApi.
final productionApiProvider = Provider<ProductionApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductionApi(apiClient: apiClient);
});

/// Riverpod provider for ProductionRepository.
final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  final productionApi = ref.watch(productionApiProvider);
  return ProductionRepository(productionApi: productionApi);
});
