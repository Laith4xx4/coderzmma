import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; 
import 'package:google_fonts/google_fonts.dart';

import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/bookings/domain/entities/booking_entity.dart';
import 'package:thesavage/features/bookings/data/models/create_booking_model.dart';
import 'package:thesavage/features/bookings/data/models/update_booking_model.dart';
import 'package:thesavage/features/bookings/presentation/bloc/booking_cubit.dart';
import 'package:thesavage/features/bookings/presentation/bloc/booking_state.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_state.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_state.dart';

import '../../../auth1/presentation/bloc/auth_cubit.dart';
import '../../../auth1/presentation/bloc/auth_state.dart';

class BookingListPage extends StatefulWidget {
  const BookingListPage({super.key});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  // Tab Selection: 0 = Upcoming, 1 = Past
  int _selectedTab = 0;

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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Segmented Tabs
            _buildTabs(),

            // Content
            Expanded(
              child: BlocConsumer<BookingCubit, BookingState>(
                listener: (context, state) {
                  if (state is BookingOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: AppTheme.successColor),
                    );
                    context.read<BookingCubit>().loadBookings(); // Refresh list after edit/cancel
                  } else if (state is BookingError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.message}'), backgroundColor: AppTheme.errorColor),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is BookingInitial || state is BookingLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                  }

                  if (state is BookingsLoaded) {
                    List<BookingEntity> bookings = state.bookings;
                    
                    // Filter Logic (Simple: Time-based if date is available, else just mock splitting)
                    // Assuming bookingTime is future for upcoming
                    final now = DateTime.now();
                    if (_selectedTab == 0) {
                      bookings = bookings.where((b) => b.bookingTime.isAfter(now.subtract(const Duration(hours: 1)))).toList();
                    } else {
                      bookings = bookings.where((b) => b.bookingTime.isBefore(now.subtract(const Duration(hours: 1)))).toList();
                    }

                    if (bookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_month, size: 64, color: AppTheme.textLight),
                            const SizedBox(height: 16),
                            Text(
                              _selectedTab == 0 ? "No upcoming bookings" : "No past bookings",
                              style: AppTheme.bodyLarge,
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
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          // Check if user is admin to show Edit button
                          // For now, let's assume Members don't see edit.
                          // Ideally we should use RoleHelper or state.
                          // Since we don't have direct role access here easily without context read again or passing it down.
                          // But we can check context.read<AuthCubit>().state.user.role
                          
                          // Quick fix: Check role from AuthCubit (assuming it's loaded)
                          final userRole = context.read<AuthCubit>().state is AuthSuccess
                              ? (context.read<AuthCubit>().state as AuthSuccess).user.role 
                              : "Client";
                          final isAdmin = userRole.toLowerCase() == 'admin';
                          final isClient = userRole.toLowerCase() == 'client';

                          return BookingCard(
                            booking: booking,
                            onEdit: isAdmin ? () => _showEditBookingDialog(context, booking) : null,
                            onCancel: () => _showCancelDialog(context, booking.id),
                          );
                        },
                      ),
                    );
                  }
                  
                   if (state is BookingError) {
                      return Center(child: TextButton(onPressed: () => context.read<BookingCubit>().loadBookings(), child: const Text("Retry")));
                   }

                  return const Center(child: Text('Something went wrong.', style: TextStyle(color: Colors.white)));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookingDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Color(0xFF112117)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             IconButton(
               icon: const Icon(Icons.arrow_back, color: Colors.white),
               onPressed: () => Navigator.pop(context) // Check if can pop?
             ), // Placeholder width if no back button needed at root
             Text("My Bookings", style: AppTheme.heading3),
             CircleAvatar(
               backgroundColor: Colors.white.withOpacity(0.1),
               child: const Icon(Icons.calendar_month, color: Colors.white),
             )
          ],
        ),
      );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1))
        ),
        child: Row(
          children: [
            _buildTabItem("Upcoming", 0),
            _buildTabItem("Past", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF112117) : AppTheme.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 14
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Dialogs (Retained logic but styled) ---

  void _showAddBookingDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final sessionsState = context.read<SessionCubit>().state;
    final membersState = context.read<MemberCubit>().state;

    List<dynamic> sessions = [];
    List<dynamic> members = [];

    if (sessionsState is SessionsLoaded) sessions = sessionsState.sessions;
    if (membersState is MembersLoaded) members = membersState.members;

    int? selectedSessionId;
    int? selectedMemberId;
    DateTime? bookingDateTime;
    int status = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: Text('Add Booking', style: AppTheme.heading3),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    dropdownColor: AppTheme.cardBackground,
                    decoration: _dialogInputDeco("Session"),
                    items: sessions.map<DropdownMenuItem<int>>((session) {
                      return DropdownMenuItem<int>(
                        value: session.id,
                        child: Text(
                          session.sessionName.isNotEmpty ? session.sessionName : 'Session #${session.id}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => selectedSessionId = value,
                    validator: (value) => value == null ? 'Select session' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    dropdownColor: AppTheme.cardBackground,
                    decoration: _dialogInputDeco("Member"),
                    items: members.map<DropdownMenuItem<int>>((member) {
                      return DropdownMenuItem<int>(
                        value: member.id,
                        child: Text(member.userName, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) => selectedMemberId = value,
                    validator: (value) => value == null ? 'Select member' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dialogInputDeco("Date & Time").copyWith(suffixIcon: const Icon(Icons.calendar_today, color: Colors.white)),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                            bookingDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        }
                      }
                    },
                    controller: TextEditingController(text: bookingDateTime?.toString() ?? ''),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && selectedSessionId != null && selectedMemberId != null) {
                  context.read<BookingCubit>().createBookingAction(
                    CreateBookingModel(
                      sessionId: selectedSessionId!,
                      memberId: selectedMemberId!,
                      bookingTime: bookingDateTime ?? DateTime.now(),
                      status: status,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: AppTheme.primaryButtonStyle,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditBookingDialog(BuildContext context, BookingEntity booking) {
     final _formKey = GlobalKey<FormState>();
    int status = booking.status == 'Pending' ? 0 : booking.status == 'Confirmed' ? 1 : 2;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Text('Edit Status', style: TextStyle(color: Colors.white)),
          content: Form(
            key: _formKey,
            child: DropdownButtonFormField<int>(
              dropdownColor: AppTheme.cardBackground,
              decoration: _dialogInputDeco("Status"),
              value: status,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Pending', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 1, child: Text('Confirmed', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 2, child: Text('Cancelled', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) => status = value ?? 0,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                context.read<BookingCubit>().updateBookingAction(booking.id, UpdateBookingModel(status: status));
                Navigator.pop(context);
              },
              style: AppTheme.primaryButtonStyle,
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to cancel?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No', style: TextStyle(color: Colors.grey))),
          TextButton(
             onPressed: () {
               // Use cancelBookingAction to properly cancel the booking
               context.read<BookingCubit>().cancelBookingAction(bookingId);
               Navigator.pop(context);
             }, 
             child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInputDeco(String label) {
      return InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor)),
      );
  }
}

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onEdit,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd').format(booking.bookingTime);
    final timeStr = DateFormat('hh:mm a').format(booking.bookingTime);

    // Color Logic
    Color badgeColor = AppTheme.successColor;
    String badgeText = booking.status.toUpperCase();
    if (booking.status == 'Pending') {
      badgeColor = Colors.orange;
    } else if (booking.status == 'Cancelled') {
      badgeColor = AppTheme.errorColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(borderRadius: 20, border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Image
                Container(
                     width: 80, height: 80,
                     decoration: BoxDecoration(
                       color: Colors.grey.shade800,
                       borderRadius: BorderRadius.circular(16),
                       image: const DecorationImage(
                         image: AssetImage('assets/placeholder_gym.png'), // Fallback
                         fit: BoxFit.cover
                       )
                     ),
                     child: const Icon(Icons.fitness_center, color: Colors.white24), 
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                         children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text(booking.sessionName, style: AppTheme.heading3.copyWith(fontSize: 18), maxLines: 2, overflow: TextOverflow.ellipsis),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           const Icon(Icons.schedule, size: 14, color: AppTheme.textLight),
                           const SizedBox(width: 4),
                           Text("$timeStr • 60 min", style: AppTheme.bodySmall),
                         ],
                       ),
                       const SizedBox(height: 2),
                       Row(
                         children: [
                           const Icon(Icons.person, size: 14, color: AppTheme.textLight),
                           const SizedBox(width: 4),
                           Text(booking.memberName, style: AppTheme.bodySmall), // Member Name for admins, or 'Coach X' if refactored
                         ],
                       )
                    ],
                  ),
                )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Row(
                 children: [
                   const Icon(Icons.location_on, size: 16, color: AppTheme.textLight),
                   const SizedBox(width: 4),
                   Text("Main Studio", style: AppTheme.bodySmall),
                 ],
               ),
               Row(
                 children: [
                   if (onEdit != null)
                      TextButton(onPressed: onEdit, child: const Text("Edit Status", style: TextStyle(color: Colors.white))),
                   if (onCancel != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        height: 32,
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.errorColor.withOpacity(0.5)),
                            backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 16)
                          ),
                          child: Text("Cancel", style: TextStyle(color: AppTheme.errorColor, fontSize: 12)),
                        ),
                      )
                 ],
               )
            ],
          )
        ],
      ),
    );
  }
}
