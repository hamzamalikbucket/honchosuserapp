import 'package:figma_new_project/view/screen/googleMap/features/uber_home_page_feature/data/data_sources/user_current_location_data_source.dart';
import 'package:geolocator/geolocator.dart';

class UserCurrentLocationDataSourceImpl extends UserCurrentLocationDataSource {
  @override
  Future<Position> getUserCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }
}
