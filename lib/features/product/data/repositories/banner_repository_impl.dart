import '../../domain/entities/banner.dart';
import '../../domain/repositories/banner_repository.dart';
import '../datasources/banner_remote_datasource.dart';
import '../mappers/banner_mapper.dart';

class BannerRepositoryImpl implements BannerRepository {
  final BannerRemoteDataSource remoteDataSource;

  BannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Banner>> getBanners({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    final models = await remoteDataSource.getBanners(
      isActive: isActive,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    );
    return BannerMapper.toEntityList(models);
  }

  @override
  Future<Banner?> getBannerById(String bannerId) async {
    final model = await remoteDataSource.getBannerById(bannerId);
    return model != null ? BannerMapper.toEntity(model) : null;
  }

  @override
  Future<List<Banner>> getActiveBanners({int? limit}) async {
    final models = await remoteDataSource.getActiveBanners(limit: limit);
    return BannerMapper.toEntityList(models);
  }

  @override
  Future<Banner> createBanner(Banner banner) async {
    final model = BannerMapper.toModel(banner);
    final createdModel = await remoteDataSource.createBanner(model);
    return BannerMapper.toEntity(createdModel);
  }

  @override
  Future<void> updateBanner(Banner banner) async {
    final model = BannerMapper.toModel(banner);
    await remoteDataSource.updateBanner(model);
  }

  @override
  Future<void> deleteBanner(String bannerId) async {
    await remoteDataSource.deleteBanner(bannerId);
  }

  @override
  Future<void> updateBannerStatus(String bannerId, bool isActive) async {
    await remoteDataSource.updateBannerStatus(bannerId, isActive);
  }

  @override
  Future<void> updateBannerOrder(String bannerId, int newOrder) async {
    await remoteDataSource.updateBannerOrder(bannerId, newOrder);
  }

  @override
  Future<void> reorderBanners(List<String> bannerIds) async {
    await remoteDataSource.reorderBanners(bannerIds);
  }

  @override
  Future<Map<String, dynamic>> getBannerStats() async {
    return await remoteDataSource.getBannerStats();
  }

  @override
  Future<List<Banner>> searchBanners(String query) async {
    final models = await remoteDataSource.searchBanners(query);
    return BannerMapper.toEntityList(models);
  }

  @override
  Future<List<Banner>> getBannersByLinkType(String linkType) async {
    final models = await remoteDataSource.getBannersByLinkType(linkType);
    return BannerMapper.toEntityList(models);
  }

  @override
  Future<List<Banner>> getBannersByLinkValue(String linkValue) async {
    final models = await remoteDataSource.getBannersByLinkValue(linkValue);
    return BannerMapper.toEntityList(models);
  }

  @override
  Stream<Banner?> watchBanner(String bannerId) {
    return remoteDataSource
        .watchBanner(bannerId)
        .map((model) => model != null ? BannerMapper.toEntity(model) : null);
  }

  @override
  Stream<List<Banner>> watchBanners({bool? isActive, int? limit}) {
    return remoteDataSource
        .watchBanners(isActive: isActive, limit: limit)
        .map((models) => BannerMapper.toEntityList(models));
  }

  @override
  Stream<List<Banner>> watchActiveBanners({int? limit}) {
    return remoteDataSource
        .watchActiveBanners(limit: limit)
        .map((models) => BannerMapper.toEntityList(models));
  }
}
