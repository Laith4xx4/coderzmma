import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/features/bookings/presentation/bloc/booking_state.dart';
import 'package:maa3/widgets/modern_card.dart';

import 'package:maa3/features/sessions/domain/entities/session_entity.dart';
import 'package:maa3/features/sessions/data/models/create_session_model.dart';
import 'package:maa3/features/coaches/domain/entities/coach_entity.dart';
import 'package:maa3/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:maa3/features/sessions/presentation/bloc/session_state.dart';
import 'package:maa3/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:maa3/features/coaches/presentation/bloc/coach_state.dart';
import 'package:maa3/features/classtypes/domain/entities/class_type_entity.dart';
import 'package:maa3/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:maa3/features/classtypes/presentation/bloc/class_type_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_state.dart';
import 'package:maa3/features/bookings/data/models/create_booking_model.dart';
import 'package:maa3/features/bookings/presentation/bloc/booking_cubit.dart';

class SessionListPage extends StatefulWidget {
  final int? classTypeId;
  final String? classTypeName;

  const SessionListPage({
    super.key,
    this.classTypeId,
    this.classTypeName,
  });

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage> {
  bool canManage = false;
  int? _currentMemberId;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadUserId();
    context.read<SessionCubit>().loadSessions();
    context.read<CoachCubit>().loadCoaches();
    context.read<ClassTypeCubit>().loadClassTypes();
    context.read<MemberCubit>().loadMembers();
    context.read<BookingCubit>().loadBookings();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("userId");
    });
  }

  Future<void> _checkPermissions() async {
    final canManageSessions = await RoleHelper.canManageSessions();
    setState(() {
      canManage = canManageSessions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final coachesState = context.watch<CoachCubit>().state;
    List<CoachEntity> coaches = [];
    if (coachesState is CoachesLoaded) {
      coaches = coachesState.coaches;
    }

    final classTypesState = context.watch<ClassTypeCubit>().state;
    List<ClassTypeEntity> classTypes = [];
    if (classTypesState is ClassTypesLoaded) {
      classTypes = classTypesState.classTypes;
    }

    final memberState = context.watch<MemberCubit>().state;
    final bookingState = context.watch<BookingCubit>().state;

    if (_currentMemberId == null && _userId != null && memberState is MembersLoaded) {
      try {
        _currentMemberId = memberState.members.firstWhere((m) => m.userId == _userId).id;
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.classTypeId == null
              ? 'Sessions'
              : 'Sessions - ${widget.classTypeName ?? 'Class ${widget.classTypeId}'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
        onPressed: () =>
            _showAddSessionDialog(context, coaches, classTypes),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      body: BlocConsumer<SessionCubit, SessionState>(
        listener: (context, state) {
          if (state is SessionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SessionInitial || state is SessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SessionsLoaded) {
            List<SessionEntity> sessions = state.sessions;

            if (widget.classTypeId != null) {
              sessions = sessions
                  .where((s) => s.classTypeId == widget.classTypeId)
                  .toList();
            }

            if (sessions.isEmpty) {
              return Center(
                child: Text(
                  widget.classTypeId == null
                      ? 'No sessions found.'
                      : 'No sessions found for this class type.',
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                
                bool isBooked = false;
                if (_currentMemberId != null && bookingState is BookingsLoaded) {
                  isBooked = bookingState.bookings.any((b) => 
                    b.sessionId == session.id && b.memberId == _currentMemberId);
                }

                return SessionCard(
                  session: session,
                  isBooked: isBooked,
                  canDelete: canManage,
                  onDelete: canManage
                      ? () => _showDeleteDialog(context, session.id)
                      : null,
                  onTap: () => _onSessionTapped(session),
                );
              },
            );
          }

          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }

  void _showAddSessionDialog(
      BuildContext context,
      List<CoachEntity> coaches,
      List<ClassTypeEntity> classTypes,
      ) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _startController = TextEditingController();
    final TextEditingController _endController = TextEditingController();
    final TextEditingController _capacityController = TextEditingController();
    final TextEditingController _descriptionController =
    TextEditingController();
    final TextEditingController _sessionNameController =
    TextEditingController(); // جديد

    int? selectedCoachId;
    int? selectedClassTypeId;
    DateTime? startDateTime;
    DateTime? endDateTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Session'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Session Name
                  TextFormField(
                    controller: _sessionNameController,
                    decoration:
                    const InputDecoration(labelText: 'Session Name'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter name' : null,
                  ),

                  // Coach Dropdown
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Coach'),
                    items: coaches.map((coach) {
                      return DropdownMenuItem(
                        value: coach.id,
                        child: Text(coach.userName),
                      );
                    }).toList(),
                    onChanged: (value) => selectedCoachId = value,
                    validator: (value) =>
                    value == null ? 'Select a coach' : null,
                  ),

                  // ClassType Dropdown
                  DropdownButtonFormField<int>(
                    decoration:
                    const InputDecoration(labelText: 'Class Type'),
                    items: classTypes.map((type) {
                      return DropdownMenuItem(
                        value: type.id,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (value) => selectedClassTypeId = value,
                    validator: (value) =>
                    value == null ? 'Select class type' : null,
                  ),

                  const SizedBox(height: 8),

                  // Start Date & Time
                  TextFormField(
                    controller: _startController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Start Date & Time',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          startDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          _startController.text =
                              '${startDateTime!.toLocal()}'.split('.').first;
                        }
                      }
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Select start date & time'
                        : null,
                  ),

                  // End Date & Time
                  TextFormField(
                    controller: _endController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'End Date & Time',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: startDateTime ?? DateTime.now(),
                        firstDate: startDateTime ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          endDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                          _endController.text =
                              '${endDateTime!.toLocal()}'.split('.').first;
                        }
                      }
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Select end date & time'
                        : null,
                  ),

                  TextFormField(
                    controller: _capacityController,
                    decoration:
                    const InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Enter capacity'
                        : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration:
                    const InputDecoration(labelText: 'Description'),
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
                if (_formKey.currentState!.validate() &&
                    selectedCoachId != null &&
                    selectedClassTypeId != null &&
                    startDateTime != null &&
                    endDateTime != null) {
                  final data = CreateSessionModel(
                    coachId: selectedCoachId!,
                    classTypeId: selectedClassTypeId!,
                    startTime: startDateTime!,
                    endTime: endDateTime!,
                    capacity: int.parse(_capacityController.text),
                    description: _descriptionController.text.isEmpty
                        ? null
                        : _descriptionController.text,
                    sessionName: _sessionNameController.text,
                  );

                  context.read<SessionCubit>().createSessionAction(data);
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

  Future<void> _onSessionTapped(SessionEntity session) async {
    // 1. Check if user is a member
    final isMember = await RoleHelper.isMember();
    // Allow clients to book as well
    final isClient = await RoleHelper.isClient();

    if (!isMember && !isClient) {
      if (canManage) {
        _showEditSessionDialog(session); // Optional: Implement edit if needed
      }
      return;
    }

    // 2. Get current User ID (Identity)
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User ID not found. Please login again.')),
      );
      return;
    }

    // 3. Find MemberProfile for this User ID
    final memberState = context.read<MemberCubit>().state;
    if (memberState is! MembersLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading member profiles... please wait.')),
      );
      return; // Or show loading
    }

    final memberProfile = memberState.members.firstWhere(
            (m) => m.userId == userId,
        orElse: () => throw Exception('Profile not found'));

    // Handle profile not found safely
    try {
      // ignore: unnecessary_null_comparison
      if (memberProfile == null) throw Exception();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Member profile not found for this user.')),
      );
      return;
    }

    // 4. Check if already booked
    final bookingState = context.read<BookingCubit>().state;
    if (bookingState is BookingsLoaded) {
      final isAlreadyBooked = bookingState.bookings.any((b) =>
      b.sessionId == session.id && b.memberId == memberProfile.id);

      if (isAlreadyBooked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already booked this session.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } else {
       // Optional: Ensure bookings are loaded if state is not BookingsLoaded?
       // For now, we assume they are loaded or loading. 
       // If critical, we could await or force load.
       context.read<BookingCubit>().loadBookings();
    }

    // 5. Show Booking Confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Session'),
        content: Text('Do you want to book "${session.sessionName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final booking = CreateBookingModel(
                sessionId: session.id,
                memberId: memberProfile.id,
                bookingTime: session.startTime, // Assuming booking time = session start
                status: 0, // Pending
              );
              context.read<BookingCubit>().createBookingAction(booking);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Booking request sent successfully!'),
                    backgroundColor: Colors.green),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  void _showEditSessionDialog(SessionEntity session) {
    // Placeholder for edit functionality if needed in future
  }

  void _showDeleteDialog(BuildContext context, int sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content:
        const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SessionCubit>().deleteSession(sessionId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  final SessionEntity session;
  final bool canDelete;
  final bool isBooked;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    this.canDelete = false,
    this.isBooked = false,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = session.startTime.toLocal().toString().split(' ').first;
    final startTime = TimeOfDay.fromDateTime(session.startTime.toLocal());
    final endTime = TimeOfDay.fromDateTime(session.endTime.toLocal());
    final duration = session.endTime.difference(session.startTime);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                  ),
                  child: const Icon(Icons.event, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: Text(
                    // إظهار اسم الجلسة بدلاً من "Session #id"
                    session.sessionName.isNotEmpty
                        ? session.sessionName
                        : 'Session #${session.id}',
                    style: AppTheme.heading3.copyWith(fontSize: 18),
                  ),
                ),
                if (isBooked)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.successColor),
                        const SizedBox(width: 4),
                        Text(
                          'BOOKED',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (canDelete && onDelete != null)
                  ActionButton(
                    icon: Icons.delete_rounded,
                    color: AppTheme.errorColor,
                    onPressed: onDelete!,
                    tooltip: 'Delete',
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
                    label: 'Coach',
                    value: session.coachName.isNotEmpty
                        ? session.coachName
                        : 'ID: ${session.coachId}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    icon: Icons.class_,
                    label: 'Class',
                    value: session.classTypeName,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.textLight.withOpacity(0.2),
                ),
                Expanded(
                  child: StatItem(
                    icon: Icons.list_alt,
                    label: 'Bookings',
                    value: '${session.bookingsCount}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Row(
              children: [
                Expanded(
                  child: StatItem(
                    icon: Icons.how_to_reg,
                    label: 'Attendance',
                    value: '${session.attendanceCount}',
                  ),
                ),
              ],
            ),
            if (session.description != null &&
                session.description!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingMD),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
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
      ),
    );
  }
}
