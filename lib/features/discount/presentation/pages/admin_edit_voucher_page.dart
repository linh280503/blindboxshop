import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/di/discount_providers.dart';
import '../../domain/entities/discount.dart';
import '../../domain/entities/discount_status.dart';
import '../../domain/entities/discount_type.dart';

class AdminEditVoucherPage extends ConsumerStatefulWidget {
  final String voucherId;

  const AdminEditVoucherPage({super.key, required this.voucherId});

  @override
  ConsumerState<AdminEditVoucherPage> createState() =>
      _AdminEditVoucherPageState();
}

class _AdminEditVoucherPageState extends ConsumerState<AdminEditVoucherPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;
  Discount? _discount;

  // Form controllers
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  final _maxDiscountAmountController = TextEditingController();
  final _usageLimitController = TextEditingController();

  // Form values
  DiscountType _discountType = DiscountType.percentage;
  DiscountStatus _status = DiscountStatus.active;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isFirstOrderOnly = false;
  List<String> _applicableProducts = [];
  List<String> _applicableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadDiscountData();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _minOrderAmountController.dispose();
    _maxDiscountAmountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscountData() async {
    try {
      final repo = ref.read(discountRepositoryProvider);
      final discounts = await repo.getAllDiscounts();
      final discount = discounts.firstWhere(
        (d) => d.id == widget.voucherId,
        orElse: () => throw Exception('Không tìm thấy mã giảm giá'),
      );

      setState(() {
        _discount = discount;
        _isLoadingData = false;
      });

      _populateForm(discount);
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      NotificationService.showError('Lỗi tải dữ liệu: ${e.toString()}');
      context.pop();
    }
  }

  void _populateForm(Discount discount) {
    _codeController.text = discount.code;
    _nameController.text = discount.name;
    _descriptionController.text = discount.description;
    _valueController.text = discount.value.toString();
    _minOrderAmountController.text = discount.minOrderAmount?.toString() ?? '';
    _maxDiscountAmountController.text =
        discount.maxDiscountAmount?.toString() ?? '';
    _usageLimitController.text = discount.usageLimit?.toString() ?? '';

    _discountType = discount.type;
    _status = discount.status;
    _startDate = discount.startDate;
    _endDate = discount.endDate;
    _isFirstOrderOnly = discount.isFirstOrderOnly;
    _applicableProducts = List.from(discount.applicableProducts);
    _applicableCategories = List.from(discount.applicableCategories);
  }

  Future<void> _updateVoucher() async {
    if (!_formKey.currentState!.validate()) return;
    if (_discount == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = ref.read(discountRepositoryProvider);
      final updatedDiscount = _discount!.copyWith(
        code: _codeController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _discountType,
        value: double.parse(_valueController.text),
        minOrderAmount: _minOrderAmountController.text.isNotEmpty
            ? double.parse(_minOrderAmountController.text)
            : null,
        maxDiscountAmount: _maxDiscountAmountController.text.isNotEmpty
            ? double.parse(_maxDiscountAmountController.text)
            : null,
        usageLimit: _usageLimitController.text.isNotEmpty
            ? int.parse(_usageLimitController.text)
            : null,
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        applicableProducts: _applicableProducts,
        applicableCategories: _applicableCategories,
        isFirstOrderOnly: _isFirstOrderOnly,
        updatedAt: DateTime.now(),
      );

      await repo.updateDiscount(widget.voucherId, updatedDiscount);

      NotificationService.showSuccess('Cập nhật mã giảm giá thành công!');

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        context.pop(true);
      }
    } catch (e) {
      NotificationService.showError(
        'Lỗi cập nhật mã giảm giá: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_discount == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy mã giảm giá')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Chỉnh sửa: ${_discount!.name}'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateVoucher,
            child: _isLoading
                ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Lưu'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usage Statistics
              _buildUsageStats(),

              SizedBox(height: 24.h),

              // Basic Information
              _buildSectionTitle('Thông tin cơ bản'),
              _buildBasicInfoSection(),

              SizedBox(height: 24.h),

              // Discount Configuration
              _buildSectionTitle('Cấu hình giảm giá'),
              _buildDiscountConfigSection(),

              SizedBox(height: 24.h),

              // Validity Period
              _buildSectionTitle('Thời gian hiệu lực'),
              _buildValiditySection(),

              SizedBox(height: 24.h),

              // Advanced Settings
              _buildSectionTitle('Cài đặt nâng cao'),
              _buildAdvancedSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageStats() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê sử dụng',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Đã sử dụng',
                  '${_discount!.usedCount}',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Giới hạn',
                  _discount!.usageLimit?.toString() ?? 'Không giới hạn',
                  AppColors.secondary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Còn lại',
                  _discount!.usageLimit != null
                      ? '${_discount!.usageLimit! - _discount!.usedCount}'
                      : 'Không giới hạn',
                  AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Code
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: 'Mã giảm giá *',
              hintText: 'VD: SALE20, WELCOME10',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mã giảm giá';
              }
              if (value.trim().length < 3) {
                return 'Mã giảm giá phải có ít nhất 3 ký tự';
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên mã giảm giá *',
              hintText: 'VD: Giảm giá 20%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên mã giảm giá';
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Mô tả',
              hintText: 'Mô tả chi tiết về mã giảm giá',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountConfigSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Discount Type
          Row(
            children: [
              Text(
                'Loại giảm giá:',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SegmentedButton<DiscountType>(
                  segments: const [
                    ButtonSegment<DiscountType>(
                      value: DiscountType.percentage,
                      label: Text('Phần trăm'),
                    ),
                    ButtonSegment<DiscountType>(
                      value: DiscountType.fixed,
                      label: Text('Số tiền'),
                    ),
                  ],
                  selected: {_discountType},
                  onSelectionChanged: (Set<DiscountType> selection) {
                    setState(() {
                      _discountType = selection.first;
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Value
          TextFormField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: _discountType == DiscountType.percentage
                  ? 'Phần trăm giảm giá (%) *'
                  : 'Số tiền giảm giá (VNĐ) *',
              hintText: _discountType == DiscountType.percentage
                  ? 'VD: 20'
                  : 'VD: 50000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập giá trị giảm giá';
              }
              final parsed = double.tryParse(value);
              if (parsed == null || parsed <= 0) {
                return 'Giá trị giảm giá phải lớn hơn 0';
              }
              if (_discountType == DiscountType.percentage && parsed > 100) {
                return 'Phần trăm giảm giá không được vượt quá 100%';
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          // Min Order Amount
          TextFormField(
            controller: _minOrderAmountController,
            decoration: InputDecoration(
              labelText: 'Đơn hàng tối thiểu (VNĐ)',
              hintText: 'VD: 500000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            keyboardType: TextInputType.number,
          ),

          SizedBox(height: 16.h),

          // Max Discount Amount
          TextFormField(
            controller: _maxDiscountAmountController,
            decoration: InputDecoration(
              labelText: 'Giảm giá tối đa (VNĐ)',
              hintText: 'VD: 100000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            keyboardType: TextInputType.number,
          ),

          SizedBox(height: 16.h),

          // Usage Limit
          TextFormField(
            controller: _usageLimitController,
            decoration: InputDecoration(
              labelText: 'Giới hạn sử dụng',
              hintText: 'VD: 100 (để trống = không giới hạn)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildValiditySection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Start Date
          ListTile(
            title: const Text('Ngày bắt đầu'),
            subtitle: Text(
              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _startDate = date;
                });
              }
            },
          ),

          // End Date
          ListTile(
            title: const Text('Ngày kết thúc'),
            subtitle: Text(
              '${_endDate.day}/${_endDate.month}/${_endDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _endDate,
                firstDate: _startDate,
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _endDate = date;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettingsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status
          Row(
            children: [
              Text(
                'Trạng thái:',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SegmentedButton<DiscountStatus>(
                  segments: const [
                    ButtonSegment<DiscountStatus>(
                      value: DiscountStatus.active,
                      label: Text('Hoạt động'),
                    ),
                    ButtonSegment<DiscountStatus>(
                      value: DiscountStatus.inactive,
                      label: Text('Tạm dừng'),
                    ),
                  ],
                  selected: {_status},
                  onSelectionChanged: (Set<DiscountStatus> selection) {
                    setState(() {
                      _status = selection.first;
                    });
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // First Order Only
          SwitchListTile(
            title: const Text('Chỉ áp dụng cho đơn hàng đầu tiên'),
            subtitle: const Text(
              'Mã giảm giá chỉ có thể sử dụng một lần cho mỗi khách hàng',
            ),
            value: _isFirstOrderOnly,
            onChanged: (value) {
              setState(() {
                _isFirstOrderOnly = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
