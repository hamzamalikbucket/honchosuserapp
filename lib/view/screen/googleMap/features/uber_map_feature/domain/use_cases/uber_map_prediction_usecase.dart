

import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/entities/uber_map_prediction_entity.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/repositories/uber_map_repository.dart';

class UberMapPredictionUsecase {
  final UberMapRepository uberMapRepository;

  UberMapPredictionUsecase({required this.uberMapRepository});

  Future<List<UberMapPredictionEntity>> call(String placeName) async {
    return await uberMapRepository.getUberMapPrediction(placeName);
  }
}
