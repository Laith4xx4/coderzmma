import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thesavage/core/app_theme.dart';

class ShimmerEffect extends StatelessWidget {
  final Widget? child; // جعلناه اختيارياً بتغييره إلى Widget?
  final bool isLoading;
  final int itemCount;
  final Widget? loadingWidget;

  const ShimmerEffect({
    super.key,
    this.child, // إزالة required
    this.isLoading = true,
    this.itemCount = 5,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    // إذا لم نكن في حالة تحميل وكان الـ child موجوداً، نعرضه
    if (!isLoading && child != null) {
      return child!;
    }

    // تصميم الهيكل العظمي الافتراضي
    final defaultLoadingWidget = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    //
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, // لون القاعدة
      highlightColor: Colors.grey[100]!, // لون التوهج المتحرك
      child: SingleChildScrollView( // لضمان عدم حدوث Overflow أثناء التحميل
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(
            itemCount,
                (index) => loadingWidget ?? defaultLoadingWidget,
          ),
        ),
      ),
    );
  }
}