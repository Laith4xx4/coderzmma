import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/widgets/modern_card.dart';
import 'package:maa3/features/bookings/domain/entities/booking_entity.dart';
import 'package:maa3/features/bookings/data/models/create_booking_model.dart';
import 'package:maa3/features/bookings/data/models/update_booking_model.dart';
import 'package:maa3/features/bookings/presentation/bloc/booking_cubit.dart';
import 'package:maa3/features/bookings/presentation/bloc/booking_state.dart';
import 'package:maa3/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:maa3/features/sessions/presentation/bloc/session_state.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_state.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().loadBookings();
    context.read<SessionCubit>().loadSessions();
    context.read<MemberCubit>().loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Bookings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookingDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is BookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingInitial || state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingsLoaded) {
            if (state.bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No bookings found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookingCubit>().loadBookings();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return BookingCard(
                    booking: booking,
                    onEdit: () => _showEditBookingDialog(context, booking),
                    onDelete: () => _showDeleteDialog(context, booking.id),
                  );
                },
              ),
            );
          }

          if (state is BookingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load bookings.\nError: ${state.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<BookingCubit>().loadBookings(),
                    child: const Text('Retry'),
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

  void _showAddBookingDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final sessionsState = context.read<SessionCubit>().state;
    final membersState = context.read<MemberCubit>().state;

    List<dynamic> sessions = [];
    List<dynamic> members = [];

    if (sessionsState is SessionsLoaded) {
      sessions = sessionsState.sessions;
    }
    if (membersState is MembersLoaded) {
      members = membersState.members;
    }

    int? selectedSessionId;
    int? selectedMemberId;
    DateTime? bookingDateTime;
    int status = 0; // 0 = Pending, 1 = Confirmed, 2 = Cancelled

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Booking'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Session'),
                    items: sessions.map<DropdownMenuItem<int>>((session) {
                      return DropdownMenuItem<int>(
                        value: session.id,
                        child: Text('Session #${session.id}'),
                      );
                    }).toList(),
                    onChanged: (value) => selectedSessionId = value,
                    validator: (value) =>
                        value == null ? 'Select a session' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Member'),
                    items: members.map<DropdownMenuItem<int>>((member) {
                      return DropdownMenuItem<int>(
                        value: member.id,
                        child: Text(member.userName),
                      );
                    }).toList(),
                    onChanged: (value) => selectedMemberId = value,
                    validator: (value) =>
                        value == null ? 'Select a member' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Booking Date & Time',
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
                          bookingDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        }
                      }
                    },
                    controller: TextEditingController(
                      text: bookingDateTime != null
                          ? bookingDateTime!
                                .toLocal()
                                .toString()
                                .split('.')
                                .first
                          : '',
                    ),
                    validator: (value) =>
                        bookingDateTime == null ? 'Select date & time' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Pending')),
                      DropdownMenuItem(value: 1, child: Text('Confirmed')),
                      DropdownMenuItem(value: 2, child: Text('Cancelled')),
                    ],
                    onChanged: (value) => status = value ?? 0,
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
                    selectedSessionId != null &&
                    selectedMemberId != null &&
                    bookingDateTime != null) {
                  context.read<BookingCubit>().createBookingAction(
                    CreateBookingModel(
                      sessionId: selectedSessionId!,
                      memberId: selectedMemberId!,
                      bookingTime: bookingDateTime!,
                      status: status,
                    ),
                  );
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

  void _showEditBookingDialog(BuildContext context, BookingEntity booking) {
    final _formKey = GlobalKey<FormState>();
    int status = booking.status == 'Pending'
        ? 0
        : booking.status == 'Confirmed'
        ? 1
        : 2;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Booking'),
          content: Form(
            key: _formKey,
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Status'),
              value: status,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Pending')),
                DropdownMenuItem(value: 1, child: Text('Confirmed')),
                DropdownMenuItem(value: 2, child: Text('Cancelled')),
              ],
              onChanged: (value) => status = value ?? 0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BookingCubit>().updateBookingAction(
                  booking.id,
                  UpdateBookingModel(status: status),
                );
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: const Text('Are you sure you want to delete this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BookingCubit>().deleteBookingAction(bookingId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BookingCard({
    super.key,
    required this.booking,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = booking.bookingTime.toLocal().toString().split(' ').first;
    final time = TimeOfDay.fromDateTime(booking.bookingTime.toLocal());

    Color statusColor = AppTheme.textSecondary;
    IconData statusIcon = Icons.pending;
    if (booking.status == 'Confirmed') {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
    } else if (booking.status == 'Cancelled') {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.cancel;
    }

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                      ),
                      child: const Icon(
                        Icons.event,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.sessionName,
                            style: AppTheme.heading3.copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(booking.memberName, style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: booking.status,
                color: statusColor,
                icon: statusIcon,
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
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  time.format(context),
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  ActionButton(
                    icon: Icons.edit_rounded,
                    color: AppTheme.infoColor,
                    onPressed: onEdit!,
                    tooltip: 'Edit',
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: AppTheme.spacingSM),
                if (onDelete != null)
                  ActionButton(
                    icon: Icons.delete_rounded,
                    color: AppTheme.errorColor,
                    onPressed: onDelete!,
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
