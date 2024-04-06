import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/data/models/uber_map_drivers_model.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_trips_history_feature/data/models/uber_trips_history_model.dart';


abstract class UberTripsHistoryDataSource {
  Stream<List<TripHistoryModel>> uberGetTripHistory(String riderId, int page);

  Future<void> uberGiveTripRating(
      double rating, String tripId, String driverId);

  Future<DriverModel> uberGetTripDriver(String driverId);
}
