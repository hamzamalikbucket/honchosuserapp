

import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/data/models/vehicle_details_model.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/repositories/uber_map_repository.dart';

class UberMapGetVehicleDetailsUseCase {
  final UberMapRepository uberMapRepository;

  UberMapGetVehicleDetailsUseCase({required this.uberMapRepository});

  Future<VehicleModel> call(String vehicleType, String driverId) {
    return uberMapRepository.getVehicleDetails(vehicleType, driverId);
  }
}
