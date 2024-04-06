

import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/entities/uber_map_get_drivers_entity.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/repositories/uber_map_repository.dart';

class UberMapGetDriversUsecase {
  final UberMapRepository uberMapRepository;

  UberMapGetDriversUsecase({required this.uberMapRepository});

  Stream<List<UberDriverEntity>> call() {
    return uberMapRepository.getAvailableDrivers();
  }
}
