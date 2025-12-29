import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/features/classtypes/domain/entities/class_type_entity.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_state.dart';

class Classtype extends StatelessWidget {
  const Classtype({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: BlocBuilder<ClassTypeCubit, ClassTypeState>(
        builder: (context, state) {
          if (state is ClassTypeInitial) {
            context.read<ClassTypeCubit>().loadClassTypes();
            return const Center(child: Text('Loading class types...'));
          }

          if (state is ClassTypeLoading) {
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
                return ClassTypeCard(item: item);
              },
            );
          }

          if (state is ClassTypeError) {
            return Center(
              child: Text(
                'Failed to load class types.\nError: ${state.message}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}

class ClassTypeCard extends StatelessWidget {
  final ClassTypeEntity item;

  const ClassTypeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text(
          '${item.description}\nDuration: ${item.durationMinutes} mins, Sessions: ${item.sessionsCount}',
        ),
        isThreeLine: true,
      ),
    );
  }
}


