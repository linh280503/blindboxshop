import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/address_remote_datasource.dart';
import '../repositories/address_repository_impl.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/usecases/get_user_addresses.dart';
import '../../domain/usecases/create_address.dart';
import '../../domain/usecases/update_address.dart';
import '../../domain/usecases/delete_address.dart';
import '../../domain/usecases/set_default_address.dart';

// Datasource provider
final addressRemoteDataSourceProvider = Provider<AddressRemoteDataSource>((
  ref,
) {
  return AddressRemoteDataSourceImpl();
});

// Repository provider
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final dataSource = ref.watch(addressRemoteDataSourceProvider);
  return AddressRepositoryImpl(remoteDataSource: dataSource);
});

// Use cases providers
final getUserAddressesProvider = Provider<GetUserAddresses>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return GetUserAddresses(repository);
});

final createAddressProvider = Provider<CreateAddress>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return CreateAddress(repository);
});

final updateAddressProvider = Provider<UpdateAddress>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return UpdateAddress(repository);
});

final deleteAddressProvider = Provider<DeleteAddress>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return DeleteAddress(repository);
});

final setDefaultAddressProvider = Provider<SetDefaultAddress>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return SetDefaultAddress(repository);
});
