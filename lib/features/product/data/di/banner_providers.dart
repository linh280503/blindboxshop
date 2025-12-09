import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/banner_remote_datasource.dart';
import '../repositories/banner_repository_impl.dart';
import '../../domain/repositories/banner_repository.dart';
import '../../domain/usecases/get_active_banners.dart';

// Datasource provider
final bannerRemoteDataSourceProvider = Provider<BannerRemoteDataSource>((ref) {
  return BannerRemoteDataSourceImpl();
});

// Repository provider
final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  final dataSource = ref.watch(bannerRemoteDataSourceProvider);
  return BannerRepositoryImpl(remoteDataSource: dataSource);
});

// Use cases providers
final getActiveBannersProvider = Provider<GetActiveBanners>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return GetActiveBanners(repository);
});
