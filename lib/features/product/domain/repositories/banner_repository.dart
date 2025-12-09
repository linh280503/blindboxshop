import '../entities/banner.dart';

/// Repository interface for Banner domain
abstract class BannerRepository {
  Future<List<Banner>> getBanners({
    bool? isActive,
    int? limit,
    String? orderBy,
    bool descending = false,
  });
  Future<Banner?> getBannerById(String bannerId);
  Future<List<Banner>> getActiveBanners({int? limit});
  Future<Banner> createBanner(Banner banner);
  Future<void> updateBanner(Banner banner);
  Future<void> deleteBanner(String bannerId);
  Future<void> updateBannerStatus(String bannerId, bool isActive);
  Future<void> updateBannerOrder(String bannerId, int newOrder);
  Future<void> reorderBanners(List<String> bannerIds);
  Future<Map<String, dynamic>> getBannerStats();
  Future<List<Banner>> searchBanners(String query);
  Future<List<Banner>> getBannersByLinkType(String linkType);
  Future<List<Banner>> getBannersByLinkValue(String linkValue);

  // Streams
  Stream<Banner?> watchBanner(String bannerId);
  Stream<List<Banner>> watchBanners({bool? isActive, int? limit});
  Stream<List<Banner>> watchActiveBanners({int? limit});
}
