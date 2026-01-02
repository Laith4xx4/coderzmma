import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/support/presentation/bloc/support_cubit.dart';
import 'package:thesavage/features/support/presentation/bloc/support_state.dart';
import 'package:thesavage/features/support/data/datasources/support_api_service.dart';
import 'package:thesavage/features/support/data/repositories/support_repository_impl.dart';
import 'package:intl/intl.dart';

class SupportMessagesPage extends StatelessWidget {
  const SupportMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SupportCubit(
        SupportRepositoryImpl(SupportApiService()),
      )..loadMessages(),
      child: const SupportMessagesView(),
    );
  }
}

class SupportMessagesView extends StatelessWidget {
  const SupportMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('SUPPORT MESSAGES', style: TextStyle(letterSpacing: 1, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SupportCubit, SupportState>(
        builder: (context, state) {
          if (state is SupportLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          } else if (state is SupportFailure) {
            return Center(child: Text('Error: ${state.error}', style: const TextStyle(color: AppTheme.errorColor)));
          } else if (state is SupportMessagesLoaded) {
            if (state.messages.isEmpty) {
              return const Center(child: Text('No messages found', style: TextStyle(color: AppTheme.textSecondary)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return _MessageCard(msg, context);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _MessageCard(Map<String, dynamic> msg, BuildContext context) {
    final date = DateTime.tryParse(msg['createdAt'] ?? '') ?? DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date.toLocal());

    return Container(
      decoration: AppTheme.cardDecoration(),
      child: ExpansionTile(
        collapsedIconColor: AppTheme.primaryColor,
        iconColor: AppTheme.primaryColor,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          msg['subject'] ?? 'No Subject',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From: ${msg['userName'] ?? 'Guest'} (${msg['email'] ?? 'No Email'})',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 10),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: AppTheme.primaryLight),
                const SizedBox(height: 8),
                Text(
                  msg['message'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context, msg['id']),
                      icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
                      label: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Delete Message?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              context.read<SupportCubit>().deleteMessage(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
