import '../../../../core/usecase/usecase.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class CreateAddress implements UseCase<String, Address> {
  final AddressRepository repository;

  CreateAddress(this.repository);

  @override
  Future<String> call(Address address) async {
    return await repository.createAddress(address);
  }
}
