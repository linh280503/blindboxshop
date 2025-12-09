import '../../../../core/usecase/usecase.dart';
import '../repositories/address_repository.dart';

/// Use case to delete an address
class DeleteAddress implements UseCase<void, String> {
  final AddressRepository repository;

  DeleteAddress(this.repository);

  @override
  Future<void> call(String addressId) async {
    await repository.deleteAddress(addressId);
  }
}
