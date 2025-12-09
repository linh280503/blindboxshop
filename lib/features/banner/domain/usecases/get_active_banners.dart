import '../../../../core/usecase/usecase.dart';
import '../entities/banner.dart';
import '../repositories/banner_repository.dart';

class GetActiveBannersParams {
  final int? limit;

  GetActiveBannersParams({this.limit});
}

class GetActiveBanners
    implements UseCase<List<Banner>, GetActiveBannersParams> {
  final BannerRepository repository;

  GetActiveBanners(this.repository);

  @override
  Future<List<Banner>> call(GetActiveBannersParams params) async {
    return await repository.getActiveBanners(limit: params.limit);
  }
}
