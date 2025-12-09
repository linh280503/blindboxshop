import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/models/address_model.dart';
import '../../data/mappers/address_mapper.dart';
import '../../data/di/address_providers.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/usecases/get_user_addresses.dart';
import '../../domain/usecases/create_address.dart';
import '../../domain/usecases/update_address.dart';
import '../../domain/usecases/delete_address.dart';
import '../../domain/usecases/set_default_address.dart';

class AddressState {
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final bool isLoading;
  final String? error;

  AddressState({
    this.addresses = const [],
    this.selectedAddress,
    this.isLoading = false,
    this.error,
  });

  AddressState copyWith({
    List<AddressModel>? addresses,
    AddressModel? selectedAddress,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((
  ref,
) {
  final repo = ref.watch(addressRepositoryProvider);
  final getUserAddresses = ref.watch(getUserAddressesProvider);
  final createAddress = ref.watch(createAddressProvider);
  final updateAddress = ref.watch(updateAddressProvider);
  final deleteAddress = ref.watch(deleteAddressProvider);
  final setDefaultAddress = ref.watch(setDefaultAddressProvider);
  return AddressNotifier(
    ref: ref,
    repository: repo,
    getUserAddressesUC: getUserAddresses,
    createAddressUC: createAddress,
    updateAddressUC: updateAddress,
    deleteAddressUC: deleteAddress,
    setDefaultAddressUC: setDefaultAddress,
  );
});

final userAddressesProvider = FutureProvider.autoDispose
    .family<List<AddressModel>, String>((ref, userId) async {
      final uc = ref.watch(getUserAddressesProvider);
      final entities = await uc(userId);
      return AddressMapper.toModelList(entities);
    });

final defaultAddressProvider = FutureProvider.autoDispose
    .family<AddressModel?, String>((ref, userId) async {
      final repo = ref.watch(addressRepositoryProvider);
      final entity = await repo.getDefaultAddress(userId);
      return entity != null ? AddressMapper.toModel(entity) : null;
    });

class AddressNotifier extends StateNotifier<AddressState> {
  final Ref ref;
  final AddressRepository repository;
  final GetUserAddresses getUserAddressesUC;
  final CreateAddress createAddressUC;
  final UpdateAddress updateAddressUC;
  final DeleteAddress deleteAddressUC;
  final SetDefaultAddress setDefaultAddressUC;

  AddressNotifier({
    required this.ref,
    required this.repository,
    required this.getUserAddressesUC,
    required this.createAddressUC,
    required this.updateAddressUC,
    required this.deleteAddressUC,
    required this.setDefaultAddressUC,
  }) : super(AddressState());

  Future<void> loadUserAddresses(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entities = await getUserAddressesUC(userId);
      state = state.copyWith(
        addresses: AddressMapper.toModelList(entities),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError(
        'Lỗi tải danh sách địa chỉ: ${e.toString()}',
      );
    }
  }

  Future<bool> createAddress(AddressModel address) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await createAddressUC(AddressMapper.toEntity(address));

      // Reload addresses
      await loadUserAddresses(address.userId);

      state = state.copyWith(isLoading: false);
      NotificationService.showSuccess('Thêm địa chỉ thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError('Lỗi thêm địa chỉ: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateAddress(AddressModel address) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await updateAddressUC(AddressMapper.toEntity(address));

      // Update local state
      final updatedAddresses = state.addresses.map((addr) {
        return addr.id == address.id ? address : addr;
      }).toList();

      state = state.copyWith(addresses: updatedAddresses, isLoading: false);
      NotificationService.showSuccess('Cập nhật địa chỉ thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError('Lỗi cập nhật địa chỉ: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId, String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await deleteAddressUC(addressId);

      // Update local state
      final updatedAddresses = state.addresses
          .where((addr) => addr.id != addressId)
          .toList();

      state = state.copyWith(addresses: updatedAddresses, isLoading: false);
      NotificationService.showSuccess('Xóa địa chỉ thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError('Lỗi xóa địa chỉ: ${e.toString()}');
      return false;
    }
  }

  Future<bool> setDefaultAddress(String addressId, String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await setDefaultAddressUC(
        SetDefaultAddressParams(addressId: addressId, userId: userId),
      );

      final updatedAddresses = state.addresses.map((addr) {
        if (addr.id == addressId) {
          return addr.copyWith(isDefault: true);
        } else {
          return addr.copyWith(isDefault: false);
        }
      }).toList();

      state = state.copyWith(
        addresses: updatedAddresses,
        selectedAddress: updatedAddresses.firstWhere(
          (addr) => addr.id == addressId,
          orElse: () => state.selectedAddress!,
        ),
        isLoading: false,
      );
      NotificationService.showSuccess('Đặt địa chỉ mặc định thành công!');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      NotificationService.showError(
        'Lỗi đặt địa chỉ mặc định: ${e.toString()}',
      );
      return false;
    }
  }

  void selectAddress(AddressModel? address) {
    state = state.copyWith(selectedAddress: address);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
