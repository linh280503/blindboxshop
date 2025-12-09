import '../../../../core/usecase/usecase.dart';
import '../repositories/address_repository.dart';

class SetDefaultAddressParams {
  final String addressId;
  final String userId;

  SetDefaultAddressParams({required this.addressId, required this.userId});
}

/// Use case to set default address
class SetDefaultAddress implements UseCase<void, SetDefaultAddressParams> {
  final AddressRepository repository;

  SetDefaultAddress(this.repository);

  @override
  Future<void> call(SetDefaultAddressParams params) async {
    await repository.setDefaultAddress(params.addressId, params.userId);
  }
}
