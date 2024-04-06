import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/entities/uber_map_get_drivers_entity.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_trips_history_feature/domain/entities/uber_trips_history_entity.dart';

abstract class UberTripHistoryRepository {
  Stream<List<TripHistoryEntity>> uberGetTripHistory(String riderId, int page);

  Future<void> uberGiveTripRating(
      double rating, String tripId, String driverId);

  Future<UberDriverEntity> uberGetTripDriver(String driverId);
}
