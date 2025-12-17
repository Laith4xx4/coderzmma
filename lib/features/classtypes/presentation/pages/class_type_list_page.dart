import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:maa3/core/app_theme.dart';
// import 'package:maa3/widgets/modern_card.dart'; // غير مستخدم حالياً
import 'package:maa3/features/classtypes/data/models/create_class_type_model.dart';
import 'package:maa3/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:maa3/features/classtypes/presentation/bloc/class_type_state.dart';

// صفحة الجلسات
import 'package:maa3/features/sessions/presentation/pages/session_list_page.dart';

import '../widget/ClassTypeCard.dart';

class ClassTypeListPage extends StatefulWidget {
  const ClassTypeListPage({super.key});

  @override
  State<ClassTypeListPage> createState() => _ClassTypeListPageState();
}

class _ClassTypeListPageState extends State<ClassTypeListPage> {
  bool canManage = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    context.read<ClassTypeCubit>().loadClassTypes();
  }

  Future<void> _checkPermissions() async {
    final canManageClassTypes = await RoleHelper.canManageClassTypes();
    setState(() {
      canManage = canManageClassTypes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Class Types',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
        onPressed: () => _showAddClassTypeDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: BlocConsumer<ClassTypeCubit, ClassTypeState>(
        listener: (context, state) {
          if (state is ClassTypeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ClassTypeInitial || state is ClassTypeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ClassTypesLoaded) {
            if (state.classTypes.isEmpty) {
              return const Center(child: Text('No class types found.'));
            }

            return ListView.builder(
              itemCount: state.classTypes.length,
              itemBuilder: (context, index) {
                final item = state.classTypes[index];

                return InkWell(
                  onTap: () {
                    // عند الضغط على نوع الكلاس -> فتح صفحة الجلسات المفلترة بهذا النوع
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionListPage(
                          classTypeId: item.id,
                          classTypeName: item.name,
                        ),
                      ),
                    );
                  },
                  child: ClassTypeCard(
                    item: item,
                    canDelete: canManage,
                    onDelete: canManage
                        ? () => _showDeleteDialog(context, item.id)
                        : null,
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }

  void _showAddClassTypeDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _descriptionController =
    TextEditingController();
    final TextEditingController _durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Class Type'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (mins)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value!.isEmpty ? 'Enter duration' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration:
                    const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final data = CreateClassTypeModel(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    durationMinutes: int.parse(_durationController.text),
                  );

                  context.read<ClassTypeCubit>().createClassType(data);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class Type'),
        content: const Text(
          'Are you sure you want to delete this class type?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ClassTypeCubit>().deleteClassType(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}