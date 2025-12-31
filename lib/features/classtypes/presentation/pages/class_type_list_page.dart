import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/core/role_helper.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/classtypes/data/models/create_class_type_model.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_state.dart';
import 'package:thesavage/features/sessions/presentation/pages/session_list_page.dart';
import 'package:thesavage/widgets/ShimmerEffect.dart';

import '../widget/ClassTypeCard.dart';

class ClassTypeListPage extends StatefulWidget {
  const ClassTypeListPage({super.key});

  @override
  State<ClassTypeListPage> createState() => _ClassTypeListPageState();
}

class _ClassTypeListPageState extends State<ClassTypeListPage>
    with AutomaticKeepAliveClientMixin {
  bool canManage = false;

  // ✅ تخزين الحجم مرة واحدة
  late double _screenWidth;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // ✅ تأجيل التحميل لما بعد البناء الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
      context.read<ClassTypeCubit>().loadClassTypes();
    });
  }

  Future<void> _checkPermissions() async {
    final result = await RoleHelper.canManageClassTypes();
    if (mounted && result != canManage) {
      setState(() => canManage = result);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ حفظ الحجم هنا بدلاً من build
    _screenWidth = MediaQuery.sizeOf(context).width;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      floatingActionButton: canManage ? _buildFAB() : null,
      body: BlocConsumer<ClassTypeCubit, ClassTypeState>(

        listenWhen: (previous, current) => current is ClassTypeError,
        listener: (context, state) {
          if (state is ClassTypeError) {
            _showErrorSnackBar(state.message);
          }
        },

        buildWhen: (previous, current) {
          return current is ClassTypeLoading ||
              current is ClassTypesLoaded ||
              current is ClassTypeInitial;
        },
        builder: (context, state) {

          if (state is ClassTypeInitial || state is ClassTypeLoading) {
            return _ShimmerList(screenWidth: _screenWidth);
          }

          if (state is ClassTypesLoaded) {
            if (state.classTypes.isEmpty) {
              return const _EmptyState();
            }
            return _ClassTypesList(
              classTypes: state.classTypes,
              canManage: canManage,
              onDelete: _showDeleteDialog,
            );
          }

          return _ErrorState(
            onRetry: () => context.read<ClassTypeCubit>().loadClassTypes(),
          );

        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryDark,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      title: const Text(
        'CLASS TYPES',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          fontSize: 18,
        ),
      ),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: FloatingActionButton(
        onPressed: () => _showAddClassTypeDialog(context),
        backgroundColor: AppTheme.primaryColor,
        elevation: 2, // ✅ تقليل الظل
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddClassTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AddClassTypeDialog(
        onAdd: (data) {
          context.read<ClassTypeCubit>().createClassType(data);
        },
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => _DeleteDialog(
        onDelete: () {
          context.read<ClassTypeCubit>().deleteClassType(id);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ قائمة الأنواع كـ Widget منفصل
// ═══════════════════════════════════════════════════════════════

class _ClassTypesList extends StatelessWidget {
  final List classTypes;
  final bool canManage;
  final Function(int) onDelete;

  const _ClassTypesList({
    required this.classTypes,
    required this.canManage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      cacheExtent: 500, // ✅ تخزين مؤقت
      itemCount: classTypes.length + 1,
      itemBuilder: (context, index) {
        if (index == classTypes.length) {
          return const SizedBox(height: 120);
        }

        final item = classTypes[index];

        return RepaintBoundary(
          // ✅ عزل إعادة الرسم
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ClassTypeItem(
              item: item,
              canManage: canManage,
              onDelete: () => onDelete(item.id),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ عنصر واحد من القائمة
// ═══════════════════════════════════════════════════════════════

class _ClassTypeItem extends StatelessWidget {
  final dynamic item;
  final bool canManage;
  final VoidCallback onDelete;

  const _ClassTypeItem({
    required this.item,
    required this.canManage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        onTap: () => _navigateToSessions(context),
        child: ClassTypeCard(
          item: item,
          canDelete: canManage,
          onDelete: canManage ? onDelete : null,
        ),
      ),
    );
  }

  void _navigateToSessions(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SessionListPage(
          classTypeId: item.id,
          classTypeName: item.name ?? "Class",
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ Shimmer List محسّن
// ═══════════════════════════════════════════════════════════════

class _ShimmerList extends StatelessWidget {
  final double screenWidth;

  const _ShimmerList({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: ShimmerEffect(
        itemCount: 5,
        loadingWidget: _ShimmerCard(screenWidth: screenWidth),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double screenWidth;

  const _ShimmerCard({required this.screenWidth});

  // ✅ ألوان ثابتة بدون withOpacity
  static const _shimmerColor = Color(0x0D1A1A1A); // 5% opacity

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        // ✅ إزالة الـ shadow أو استخدام خفيف جداً
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _shimmerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _shimmerColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: screenWidth * 0.4,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _shimmerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: _shimmerColor,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ Empty State ثابت
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: AppTheme.textLight.withAlpha(128), // ✅ withAlpha بدلاً من withOpacity
          ),
          const SizedBox(height: 16),
          Text('No class types found.', style: AppTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ Error State منفصل
// ═══════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Text('Something went wrong.', style: AppTheme.bodyLarge),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Try Again',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ Dialog لإضافة نوع جديد - مع إدارة صحيحة للـ Controllers
// ═══════════════════════════════════════════════════════════════

class _AddClassTypeDialog extends StatefulWidget {
  final Function(CreateClassTypeModel) onAdd;

  const _AddClassTypeDialog({required this.onAdd});

  @override
  State<_AddClassTypeDialog> createState() => _AddClassTypeDialogState();
}

class _AddClassTypeDialogState extends State<_AddClassTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _durationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      title: const Text(
        'Add Class Type',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _durationController,
                label: 'Duration (mins)',
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter duration' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _handleAdd,
          style: AppTheme.primaryButtonStyle,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }

  void _handleAdd() {
    if (_formKey.currentState!.validate()) {
      final data = CreateClassTypeModel(
        name: _nameController.text,
        description: _descriptionController.text,
        durationMinutes: int.parse(_durationController.text),
      );
      widget.onAdd(data);
      Navigator.pop(context);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ Dialog للحذف
// ═══════════════════════════════════════════════════════════════

class _DeleteDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteDialog({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      title: const Text(
        'Delete Class Type',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Are you sure you want to delete this class type?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
  }

