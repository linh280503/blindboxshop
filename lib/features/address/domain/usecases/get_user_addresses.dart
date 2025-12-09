import '../../../../core/usecase/usecase.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

/// Use case to get user addresses
class GetUserAddresses implements UseCase<List<Address>, String> {
  final AddressRepository repository;

  GetUserAddresses(this.repository);

  @override
  Future<List<Address>> call(String userId) async {
    return await repository.getUserAddresses(userId);
  }
}
