import '../entities/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getUserAddresses(String userId);
  Future<Address?> getDefaultAddress(String userId);
  Future<Address?> getAddressById(String addressId);
  Future<String> createAddress(Address address);
  Future<void> updateAddress(Address address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId, String userId);
  bool validateAddress(Address address);
  List<String> getCities();
  List<String> getDistricts(String city);
  List<String> getWards(String district);
}
