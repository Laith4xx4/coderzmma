import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/widgets/modern_card.dart';
import 'package:thesavage/features/sessions/domain/entities/session_entity.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_state.dart';

class Sessionw extends StatefulWidget {
  const Sessionw({super.key});

  @override
  State<Sessionw> createState() => _SessionwState();
}

class _SessionwState extends State<Sessionw> {
  @override
  void initState() {
    super.initState();
    context.read<SessionCubit>().loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Sessions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<SessionCubit, SessionState>(
        listener: (context, state) {
          if (state is SessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading sessions: ${state.message}'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SessionInitial || state is SessionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SessionsLoaded) {
            if (state.sessions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sessions found.',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<SessionCubit>().loadSessions();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                itemCount: state.sessions.length,
                itemBuilder: (context, index) {
                  final session = state.sessions[index];
                  return SessionCard(session: session);
                },
              ),
            );
          }

          if (state is SessionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load sessions.\nError: ${state.message}',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final SessionEntity session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final startDate = session.startTime.toLocal().toString().split(' ').first;
    final startTime = TimeOfDay.fromDateTime(session.startTime.toLocal());
    final endTime = TimeOfDay.fromDateTime(session.endTime.toLocal());
    final duration = session.endTime.difference(session.startTime);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: const Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session #${session.id}',
                      style: AppTheme.heading3.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      startDate,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${startTime.format(context)} - ${endTime.format(context)}',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${duration.inMinutes} min',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.infoColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Row(
            children: [
              Expanded(
                child: StatItem(
                  icon: Icons.people,
                  label: 'Capacity',
                  value: '${session.capacity}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.textLight.withOpacity(0.2),
              ),
              Expanded(
                child: StatItem(
                  icon: Icons.person,
                  label: 'Coach ID',
                  value: '${session.coachId}',
                ),
              ),
            ],
          ),
          if (session.description != null && session.description!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(
                  color: AppTheme.textLight.withOpacity(0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Expanded(
                    child: Text(
                      session.description!,
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
