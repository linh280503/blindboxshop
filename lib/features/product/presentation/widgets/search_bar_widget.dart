// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final String? hintText;

  const SearchBarWidget({super.key, this.hintText});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      context.push('/products');
      return;
    }
    final encoded = Uri.encodeComponent(query);
    context.push('/products?q=$encoded');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      alignment: Alignment.center,
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.textSecondary, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submitSearch(),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hintText ?? 'Tìm kiếm Blind Box, Figure...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: _submitSearch,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: AppColors.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
