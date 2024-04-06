import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/repositories/uber_map_repository.dart';

class UberCancelTripUseCase {
  final UberMapRepository uberMapRepository;

  UberCancelTripUseCase({required this.uberMapRepository});

  Future<void> call(String tripId, bool isNewTripGeneration) async {
    return await uberMapRepository.cancelTrip(tripId, isNewTripGeneration);
  }
}
