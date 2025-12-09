import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/address_provider.dart';
import '../widgets/address_card.dart';
import '../../data/models/address_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AddressListPage extends ConsumerWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressProvider);
    final authState = ref.watch(authProvider);
    final userId = authState.user?.uid ?? '';

    if (userId.isNotEmpty &&
        addressState.addresses.isEmpty &&
        !addressState.isLoading) {
      Future.microtask(
        () => ref.read(addressProvider.notifier).loadUserAddresses(userId),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Địa chỉ giao hàng',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.push('/add-address');
            },
            child: Text(
              'Thêm mới',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: addressState.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : addressState.addresses.isEmpty
          ? _buildEmptyState(context)
          : _buildAddressList(context, ref, addressState),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 80.sp,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'Chưa có địa chỉ nào',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Thêm địa chỉ để nhận hàng',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.push('/add-address');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Thêm địa chỉ',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(
    BuildContext context,
    WidgetRef ref,
    AddressState addressState,
  ) {
    final uid = ref.read(authProvider).user?.uid ?? '';
    return RefreshIndicator(
      onRefresh: () async {
        if (uid.isNotEmpty) {
          await ref.read(addressProvider.notifier).loadUserAddresses(uid);
        }
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: addressState.addresses.length,
        itemBuilder: (context, index) {
          final address = addressState.addresses[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: AddressCard(
              address: address,
              onEdit: () {
                context.push('/edit-address', extra: address);
              },
              onDelete: () {
                _showDeleteDialog(context, ref, address);
              },
              onSetDefault: () {
                if (uid.isNotEmpty) {
                  ref
                      .read(addressProvider.notifier)
                      .setDefaultAddress(address.id, uid);
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    AddressModel address,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xóa địa chỉ',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa địa chỉ này không?',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Hủy',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(addressProvider.notifier)
                  .deleteAddress(address.id, address.userId);

              if (success && context.mounted) {
                // reload list after deletion to ensure UI updates
                final uid = ref.read(authProvider).user?.uid ?? '';
                if (uid.isNotEmpty) {
                  await ref
                      .read(addressProvider.notifier)
                      .loadUserAddresses(uid);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa địa chỉ'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text('Xóa', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
