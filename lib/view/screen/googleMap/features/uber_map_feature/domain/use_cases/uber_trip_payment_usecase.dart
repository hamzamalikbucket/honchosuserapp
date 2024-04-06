import 'package:figma_new_project/view/screen/googleMap/features/uber_map_feature/domain/repositories/uber_map_repository.dart';


class UberTripPaymentUseCase {
  final UberMapRepository uberMapRepository;

  UberTripPaymentUseCase({required this.uberMapRepository});

  Future<String> call(String riderId, String driverId, int tripAmount,
      String tripId, String payMode) async {
    return await uberMapRepository.tripPayment(
        riderId, driverId, tripAmount, tripId, payMode);
  }
}
