import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/features/classtypes/data/models/create_class_type_model.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_cubit.dart';

class Showaddclasstypedialog extends StatelessWidget {
  Showaddclasstypedialog({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
  }
}