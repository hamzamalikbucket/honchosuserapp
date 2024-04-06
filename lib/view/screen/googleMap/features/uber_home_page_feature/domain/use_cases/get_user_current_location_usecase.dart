import 'package:figma_new_project/view/screen/googleMap/features/uber_home_page_feature/domain/repositories/user_current_location_repository.dart';
import 'package:geolocator/geolocator.dart';

class GetUserCurrentLocationUsecase {
  final UserCurrentLocationRepository userCurrentLocationRepository;

  GetUserCurrentLocationUsecase({required this.userCurrentLocationRepository});

  Future<Position> call() async {
    return await userCurrentLocationRepository.getUserCurrentLocation();
  }
}
