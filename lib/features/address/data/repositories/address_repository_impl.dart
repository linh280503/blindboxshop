import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';
import '../mappers/address_mapper.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Address>> getUserAddresses(String userId) async {
    final models = await remoteDataSource.getUserAddresses(userId);
    return AddressMapper.toEntityList(models);
  }

  @override
  Future<Address?> getDefaultAddress(String userId) async {
    final model = await remoteDataSource.getDefaultAddress(userId);
    return model != null ? AddressMapper.toEntity(model) : null;
  }

  @override
  Future<Address?> getAddressById(String addressId) async {
    final model = await remoteDataSource.getAddressById(addressId);
    return model != null ? AddressMapper.toEntity(model) : null;
  }

  @override
  Future<String> createAddress(Address address) async {
    final model = AddressMapper.toModel(address);
    return await remoteDataSource.createAddress(model);
  }

  @override
  Future<void> updateAddress(Address address) async {
    final model = AddressMapper.toModel(address);
    await remoteDataSource.updateAddress(model);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await remoteDataSource.deleteAddress(addressId);
  }

  @override
  Future<void> setDefaultAddress(String addressId, String userId) async {
    await remoteDataSource.setDefaultAddress(addressId, userId);
  }

  @override
  bool validateAddress(Address address) {
    return address.isValid;
  }

  @override
  List<String> getCities() {
    return remoteDataSource.getCities();
  }

  @override
  List<String> getDistricts(String city) {
    return remoteDataSource.getDistricts(city);
  }

  @override
  List<String> getWards(String district) {
    return remoteDataSource.getWards(district);
  }
}
