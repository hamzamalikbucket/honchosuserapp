

import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/data/models/rental_charges_model.dart';
import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/repositories/uber_map_repository.dart';

class UberMapGetRentalChargesUseCase {
  final UberMapRepository uberMapRepository;

  UberMapGetRentalChargesUseCase({required this.uberMapRepository});

  Future<RentalChargeModel> call(double kms) async {
    return await uberMapRepository.getRentalChargeForVehicle(kms);
  }
}
