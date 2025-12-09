import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../address/presentation/providers/address_provider.dart';
import '../../../address/presentation/widgets/address_card.dart';
import '../../../address/data/models/address_model.dart';
import '../../../address/data/di/address_providers.dart';
import '../providers/auth_provider.dart';

class DeliveryAddressPage extends ConsumerStatefulWidget {
  const DeliveryAddressPage({super.key});

  @override
  ConsumerState<DeliveryAddressPage> createState() =>
      _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends ConsumerState<DeliveryAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _noteController = TextEditingController();

  AddressModel? _editingAddress;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authProvider).user?.uid ?? '';

    final defaultAddressAsync = uid.isEmpty
        ? const AsyncValue<AddressModel?>.data(null)
        : ref.watch(defaultAddressProvider(uid));

    final addressState = ref.watch(addressProvider);
    // Lazy-load all addresses when page opens
    if (uid.isNotEmpty &&
        !addressState.isLoading &&
        addressState.addresses.isEmpty) {
      Future.microtask(
        () => ref.read(addressProvider.notifier).loadUserAddresses(uid),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Địa chỉ giao hàng',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddAddressDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Default address (from Firestore)
            defaultAddressAsync.when(
              data: (addr) {
                if (addr == null) return const SizedBox.shrink();
                return AddressCard(
                  address: addr,
                  onEdit: () => _showEditAddressDialog(addr),
                  onDelete: () => _showDeleteDialog(addr),
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => const SizedBox.shrink(),
            ),
            SizedBox(height: 16.h),

            // Other addresses
            Text(
              'Địa chỉ khác',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),

            if (addressState.isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else ...[
              if (addressState.addresses.where((a) => !(a.isDefault)).isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Chưa có địa chỉ nào',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton.icon(
                        onPressed: _showAddAddressDialog,
                        icon: Icon(Icons.add, size: 16.sp),
                        label: Text(
                          'Thêm địa chỉ',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  itemCount: addressState.addresses
                      .where((a) => !a.isDefault)
                      .length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final others = addressState.addresses
                        .where((a) => !a.isDefault)
                        .toList();
                    final address = others[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: AddressCard(
                        address: address,
                        onEdit: () => _showEditAddressDialog(address),
                        onDelete: () async {
                          final success = await ref
                              .read(addressProvider.notifier)
                              .deleteAddress(address.id, address.userId);
                          if (success && mounted) {
                            await ref
                                .read(addressProvider.notifier)
                                .loadUserAddresses(uid);
                          }
                        },
                        onSetDefault: () async {
                          final ok = await ref
                              .read(addressProvider.notifier)
                              .setDefaultAddress(address.id, uid);
                          if (ok && mounted) {
                            await ref
                                .read(addressProvider.notifier)
                                .loadUserAddresses(uid);
                            ref.invalidate(defaultAddressProvider(uid));
                          }
                        },
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 16.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  'Thêm địa chỉ mới',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Họ và tên người nhận',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập họ và tên';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        _buildTextField(
                          controller: _cityController,
                          label: 'Tỉnh/Thành phố',
                          icon: Icons.location_city,
                        ),
                        SizedBox(height: 16.h),

                        _buildTextField(
                          controller: _districtController,
                          label: 'Quận/Huyện',
                          icon: Icons.location_on,
                        ),
                        SizedBox(height: 16.h),

                        _buildTextField(
                          controller: _wardController,
                          label: 'Phường/Xã',
                          icon: Icons.location_on_outlined,
                        ),
                        SizedBox(height: 16.h),

                        _buildTextField(
                          controller: _addressController,
                          label: 'Địa chỉ chi tiết',
                          icon: Icons.home_outlined,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập địa chỉ chi tiết';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        _buildTextField(
                          controller: _noteController,
                          label: 'Ghi chú (tùy chọn)',
                          icon: Icons.note_outlined,
                          maxLines: 2,
                        ),
                        SizedBox(height: 16.h),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Lưu địa chỉ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: validator,
      onTap: onTap,
      style: TextStyle(fontSize: 16.sp),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
      ),
    );
  }

  void _showEditAddressDialog(AddressModel address) {
    // Prefill
    _editingAddress = address;
    _nameController.text = address.name;
    _phoneController.text = address.phone;
    _addressController.text = address.address;
    _cityController.text = address.city;
    _districtController.text = address.district;
    _wardController.text = address.ward;
    _noteController.text = address.note ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 16.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Sửa địa chỉ',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Họ và tên người nhận',
                          icon: Icons.person_outline,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Vui lòng nhập họ và tên'
                              : null,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _cityController,
                          label: 'Tỉnh/Thành phố',
                          icon: Icons.location_city,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _districtController,
                          label: 'Quận/Huyện',
                          icon: Icons.location_on,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _wardController,
                          label: 'Phường/Xã',
                          icon: Icons.location_on_outlined,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Địa chỉ chi tiết',
                          icon: Icons.home_outlined,
                          maxLines: 3,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Vui lòng nhập địa chỉ chi tiết'
                              : null,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _noteController,
                          label: 'Ghi chú (tùy chọn)',
                          icon: Icons.note_outlined,
                          maxLines: 2,
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _updateAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Cập nhật',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa địa chỉ', style: TextStyle(fontSize: 18.sp)),
        content: Text(
          'Bạn có chắc chắn muốn xóa địa chỉ này?',
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final uid = ref.read(authProvider).user?.uid ?? '';
              if (uid.isEmpty) return;

              final success = await ref
                  .read(addressProvider.notifier)
                  .deleteAddress(address.id, address.userId);
              if (!mounted) return;
              if (success) {
                await ref.read(addressProvider.notifier).loadUserAddresses(uid);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa địa chỉ thành công')),
                );
              }
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAddress() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authProvider).user?.uid ?? '';
    if (uid.isEmpty || _editingAddress == null) return;

    final now = DateTime.now();
    final updated = _editingAddress!.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      ward: _wardController.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      updatedAt: now,
    );

    final success = await ref
        .read(addressProvider.notifier)
        .updateAddress(updated);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      await ref.read(addressProvider.notifier).loadUserAddresses(uid);
      ref.invalidate(defaultAddressProvider(uid));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật địa chỉ thành công')),
      );
    } else {
      final error = ref.read(addressProvider).error;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Có lỗi xảy ra')));
    }
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(authProvider).user?.uid ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn cần đăng nhập để lưu địa chỉ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final addressRepo = ref.read(addressRepositoryProvider);
    final existing = await addressRepo.getUserAddresses(uid);
    final shouldBeDefault = existing.isEmpty;

    final address = AddressModel(
      id: '',
      userId: uid,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      ward: _wardController.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      isDefault: shouldBeDefault,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await ref
        .read(addressProvider.notifier)
        .createAddress(address);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      // refresh list and default
      await ref.read(addressProvider.notifier).loadUserAddresses(uid);
      ref.invalidate(defaultAddressProvider(uid));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu địa chỉ thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(addressProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
