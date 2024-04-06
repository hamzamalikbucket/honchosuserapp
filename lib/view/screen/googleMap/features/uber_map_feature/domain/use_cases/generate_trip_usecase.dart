

import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/data/models/generate_trip_model.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/repositories/uber_map_repository.dart';

class UberMapGenerateTripUseCase {
  final UberMapRepository uberMapRepository;

  UberMapGenerateTripUseCase({required this.uberMapRepository});

  Stream call(GenerateTripModel generateTripModel) {
    return uberMapRepository.generateTrip(generateTripModel);
  }
}
