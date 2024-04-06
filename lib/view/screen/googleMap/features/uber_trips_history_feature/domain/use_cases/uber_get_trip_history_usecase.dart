

import 'package:figma_new_project/view/screen/googleMap/features/uber_trips_history_feature/domain/entities/uber_trips_history_entity.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_trips_history_feature/domain/repositories/uber_trips_history_repository.dart';

class UberGetTripHistoryUsecase {
  final UberTripHistoryRepository uberTripHistoryRepository;

  UberGetTripHistoryUsecase({required this.uberTripHistoryRepository});

  Stream<List<TripHistoryEntity>> call(String riderId, int page) {
    return uberTripHistoryRepository.uberGetTripHistory(riderId, page);
  }
}
