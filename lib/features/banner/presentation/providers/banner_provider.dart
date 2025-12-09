import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/banner_model.dart';
import '../../data/mappers/banner_mapper.dart';
import '../../data/di/banner_providers.dart';
import '../../domain/usecases/get_active_banners.dart';
import '../../domain/repositories/banner_repository.dart';

final activeBannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  try {
    final usecase = ref.watch(getActiveBannersProvider);
    final entities = await usecase(GetActiveBannersParams());
    return BannerMapper.toModelList(entities);
  } catch (e) {
    NotificationService.showError('Lỗi tải banner: ${e.toString()}');
    return [];
  }
});

final bannerNotifierProvider =
    StateNotifierProvider<BannerNotifier, List<BannerModel>>((ref) {
      final repo = ref.watch(bannerRepositoryProvider);
      return BannerNotifier(repo);
    });

class BannerNotifier extends StateNotifier<List<BannerModel>> {
  final BannerRepository _repository;

  BannerNotifier(this._repository) : super([]);

  Future<void> loadBanners({bool? isActive, int? limit}) async {
    try {
      final entities = await _repository.getBanners(
        isActive: isActive,
        limit: limit,
        orderBy: 'order',
        descending: false,
      );
      state = BannerMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError(
        'Lỗi tải danh sách banner: ${e.toString()}',
      );
    }
  }

  Future<void> searchBanners(String query) async {
    try {
      final entities = await _repository.searchBanners(query);
      state = BannerMapper.toModelList(entities);
    } catch (e) {
      NotificationService.showError('Lỗi tìm kiếm banner: ${e.toString()}');
    }
  }

  Future<void> addBanner(BannerModel banner) async {
    try {
      final created = await _repository.createBanner(
        BannerMapper.toEntity(banner),
      );
      state = [BannerMapper.toModel(created), ...state];
      NotificationService.showSuccess('Thêm banner thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi thêm banner: ${e.toString()}');
    }
  }

  Future<void> updateBanner(BannerModel banner) async {
    try {
      await _repository.updateBanner(BannerMapper.toEntity(banner));

      final index = state.indexWhere((b) => b.id == banner.id);
      if (index != -1) {
        final updated = List<BannerModel>.from(state);
        updated[index] = banner;
        state = updated;
      }

      NotificationService.showSuccess('Cập nhật banner thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi cập nhật banner: ${e.toString()}');
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      await _repository.deleteBanner(bannerId);
      state = state.where((b) => b.id != bannerId).toList();
      NotificationService.showSuccess('Xóa banner thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi xóa banner: ${e.toString()}');
    }
  }

  Future<void> updateBannerOrder(String bannerId, int newOrder) async {
    try {
      await _repository.updateBannerOrder(bannerId, newOrder);

      final index = state.indexWhere((b) => b.id == bannerId);
      if (index != -1) {
        final updated = List<BannerModel>.from(state);
        updated[index] = updated[index].copyWith(order: newOrder);
        state = updated;
      }

      NotificationService.showSuccess('Cập nhật thứ tự banner thành công!');
    } catch (e) {
      NotificationService.showError(
        'Lỗi cập nhật thứ tự banner: ${e.toString()}',
      );
    }
  }

  Future<void> reorderBanners(List<String> bannerIds) async {
    try {
      await _repository.reorderBanners(bannerIds);
      await loadBanners();
      NotificationService.showSuccess('Sắp xếp banner thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi sắp xếp banner: ${e.toString()}');
    }
  }

  Future<void> activateBanner(String bannerId) async {
    try {
      await _repository.updateBannerStatus(bannerId, true);

      final index = state.indexWhere((b) => b.id == bannerId);
      if (index != -1) {
        final updated = List<BannerModel>.from(state);
        updated[index] = updated[index].copyWith(isActive: true);
        state = updated;
      }

      NotificationService.showSuccess('Kích hoạt banner thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi kích hoạt banner: ${e.toString()}');
    }
  }

  Future<void> deactivateBanner(String bannerId) async {
    try {
      await _repository.updateBannerStatus(bannerId, false);

      final index = state.indexWhere((b) => b.id == bannerId);
      if (index != -1) {
        final updated = List<BannerModel>.from(state);
        updated[index] = updated[index].copyWith(isActive: false);
        state = updated;
      }

      NotificationService.showSuccess('Vô hiệu hóa banner thành công!');
    } catch (e) {
      NotificationService.showError('Lỗi vô hiệu hóa banner: ${e.toString()}');
    }
  }
}

// Stream providers (repository streams)
final bannerStreamProvider = StreamProvider.family<BannerModel?, String>((
  ref,
  bannerId,
) {
  final repo = ref.watch(bannerRepositoryProvider);
  return repo
      .watchBanner(bannerId)
      .map((entity) => entity != null ? BannerMapper.toModel(entity) : null);
});

final bannersStreamProvider =
    StreamProvider.family<List<BannerModel>, Map<String, dynamic>>((
      ref,
      params,
    ) {
      final repo = ref.watch(bannerRepositoryProvider);
      return repo
          .watchBanners(
            isActive: params['isActive'] as bool?,
            limit: params['limit'] as int?,
          )
          .map(BannerMapper.toModelList);
    });

final activeBannersStreamProvider = StreamProvider<List<BannerModel>>((ref) {
  final repo = ref.watch(bannerRepositoryProvider);
  return repo.watchActiveBanners().map(BannerMapper.toModelList);
});

final bannerStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(bannerRepositoryProvider);
  return await repo.getBannerStats();
});
