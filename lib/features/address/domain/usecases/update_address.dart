import '../../../../core/usecase/usecase.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

/// Use case to update an address
class UpdateAddress implements UseCase<void, Address> {
  final AddressRepository repository;

  UpdateAddress(this.repository);

  @override
  Future<void> call(Address address) async {
    await repository.updateAddress(address);
  }
}
