import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thesavage/core/role_helper.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/sessions/domain/entities/session_entity.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_state.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_state.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_state.dart';

import 'package:thesavage/features/bookings/data/models/create_booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// RBAC Imports
import 'package:thesavage/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_state.dart';
import 'package:thesavage/features/coaches/domain/entities/coach_entity.dart';
import 'package:thesavage/features/sessions/data/models/create_session_model.dart';
import 'package:thesavage/features/sessions/data/models/update_session_model.dart';

import '../../../bookings/presentation/bloc/booking_cubit.dart';
import '../../../bookings/presentation/bloc/booking_state.dart';
import 'package:thesavage/features/auth1/presentation/bloc/auth_cubit.dart';
import 'package:thesavage/features/auth1/presentation/bloc/auth_state.dart';

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
  DateTime _selectedDate = DateTime.now();
  int? _selectedClassTypeId;
  int? _selectedSessionIdForBooking; // Track selected session for "Confirm"
  SessionEntity? _selectedSessionEntity; // Track entity for bottom bar display

  String? _userId;
  int? _currentMemberId;
  bool _canManage = false;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _selectedClassTypeId = widget.classTypeId;
    _checkUser();
    context.read<SessionCubit>().loadSessions();
    context.read<ClassTypeCubit>().loadClassTypes();
    context.read<MemberCubit>().loadMembers();
    context.read<CoachCubit>().loadCoaches();
    context.read<BookingCubit>().loadBookings();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString("userId");
    if (savedUserId != null && savedUserId.isNotEmpty) {
      _userId = savedUserId;
    }
    _canManage = await RoleHelper.canManageSessions();
    _isMember = await RoleHelper.isMember();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Resolve Member ID
    final memberState = context.watch<MemberCubit>().state;
    if (_currentMemberId == null && _userId != null && _userId!.isNotEmpty && memberState is MembersLoaded) {
       try { 
         _currentMemberId = memberState.members.firstWhere((m) => m.userId == _userId).id; 
         print("SessionListPage: Resolved Member ID $_currentMemberId for User ID $_userId");
       } catch (e) {
         print("SessionListPage: Could not find member for User ID $_userId. Error: $e");
       }
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking Successful!"), backgroundColor: Colors.green),
              );
              setState(() {
                _selectedSessionIdForBooking = null;
                _selectedSessionEntity = null;
              });
              context.read<SessionCubit>().loadSessions(); 
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.message}"), backgroundColor: Colors.red),
              );
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              print("SessionListPage: AuthSuccess received, updating userId: ${state.user.id}");
              setState(() {
                _userId = state.user.id;
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        floatingActionButton: _canManage ? FloatingActionButton(
          onPressed: () => _showSessionDialog(),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.black),
        ) : null,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Column(
                      children: [
                        _buildDateStrip(),
                        _buildFilters(),
                        const SizedBox(height: 16),
                        _buildSessionsList(),
                      ],
                    ),
                  ),
                ],
              ),
              // Floating Bottom Bar for Booking Confirmation
              if (_selectedSessionIdForBooking != null && _selectedSessionEntity != null && _isMember)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _buildBookingBottomBar(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: const CircleBorder(),
            ),
          ),
          Text(
            widget.classTypeName ?? "Book Session",
            style: AppTheme.heading3,
          ),
          IconButton(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Advanced filters coming soon!"), backgroundColor: AppTheme.primaryColor));
            },
            icon: const Icon(Icons.filter_list, color: Colors.white),
             style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    final now = DateTime.now();
    final days = List.generate(14, (index) => now.add(Duration(days: index)));

    return Container(
      height: 100, 
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          
          return GestureDetector(
            onTap: () => setState(() { 
                _selectedDate = date; 
                _selectedSessionIdForBooking = null; 
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
                ),
                boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return BlocBuilder<ClassTypeCubit, ClassTypeState>(
      builder: (context, state) {
        if (state is ClassTypesLoaded) {
          final types = state.classTypes;
          return SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: types.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                 if (index == 0) {
                   final isSelected = _selectedClassTypeId == null;
                   return ChoiceChip(
                     label: const Text("All Classes"),
                     selected: isSelected,
                     onSelected: (v) => setState(() {
                       _selectedClassTypeId = null;
                       _selectedSessionIdForBooking = null;
                     }),
                     selectedColor: Colors.white,
                     backgroundColor: Colors.transparent,
                     labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                     shape: const StadiumBorder(side: BorderSide(color: Colors.white12)),
                   );
                 }
                 final type = types[index - 1];
                 final isSelected = _selectedClassTypeId == type.id;
                 return ChoiceChip(
                   label: Text(type.name ?? "Class"),
                   selected: isSelected,
                   onSelected: (v) => setState(() {
                      _selectedClassTypeId = v ? type.id : null;
                      _selectedSessionIdForBooking = null;
                   }),
                   selectedColor: Colors.white,
                   backgroundColor: AppTheme.surfaceColor,
                   labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontWeight: FontWeight.bold),
                   shape: const StadiumBorder(side: BorderSide(color: Colors.white10)),
                 );
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSessionsList() {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is SessionLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        
        if (state is SessionsLoaded) {
           List<SessionEntity> sessions = state.sessions.where((s) => DateUtils.isSameDay(s.startTime, _selectedDate)).toList();
           
           if (_selectedClassTypeId != null) {
             sessions = sessions.where((s) => s.classTypeId == _selectedClassTypeId).toList();
           }
           
           sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
 
           if (sessions.isEmpty) return _buildEmptyState();
 
           return Expanded(
             child: ListView.separated(
               padding: const EdgeInsets.fromLTRB(16, 0, 16, 120), 
               itemCount: sessions.length,
               separatorBuilder: (_, __) => const SizedBox(height: 12),
               itemBuilder: (context, index) {
                 final session = sessions[index];
                 return _buildSessionCard(session);
               },
             ),
           );
        }
        
        if (state is SessionError) return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)));
        return const SizedBox();
      },
    );
  }

  Widget _buildSessionCard(SessionEntity session) {
    bool isSelected = _selectedSessionIdForBooking == session.id;
    bool isFull = session.bookingsCount >= session.capacity;
    
    // Check if current user already booked this session
    bool isAlreadyBooked = false;
    final bookingState = context.watch<BookingCubit>().state;
    if (bookingState is BookingsLoaded && _currentMemberId != null) {
      isAlreadyBooked = bookingState.bookings.any((b) => b.sessionId == session.id && b.memberId == _currentMemberId);
    }
    
    Color typeColor = AppTheme.primaryColor; 
    Color typeBg = AppTheme.primaryColor.withOpacity(0.1);
    if ((session.classTypeName ?? "").toLowerCase().contains("yoga")) {
      typeColor = Colors.purpleAccent;
      typeBg = Colors.purpleAccent.withOpacity(0.1);
    } else if ((session.classTypeName ?? "").toLowerCase().contains("strength")) {
       typeColor = Colors.blueAccent;
       typeBg = Colors.blueAccent.withOpacity(0.1);
    }
    
    return GestureDetector(
      onTap: () {
        if (!isFull && _isMember) {
          setState(() {
            _selectedSessionIdForBooking = session.id;
            _selectedSessionEntity = session;
          });
        }
      },
      onLongPress: _canManage ? () => _showManagementOptions(session) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFull 
            ? AppTheme.errorColor.withOpacity(0.1) 
            : (isSelected ? AppTheme.primaryColor.withOpacity(0.05) : AppTheme.surfaceColor),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFull 
              ? AppTheme.errorColor 
              : (isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.05)),
            width: (isSelected || isFull) ? 2 : 1,
          ),
          boxShadow: isFull 
            ? [BoxShadow(color: AppTheme.errorColor.withOpacity(0.1), blurRadius: 10)]
            : (isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.1), blurRadius: 10)] : []),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1)))
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('hh:mm').format(session.startTime),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('a').format(session.startTime),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (session.classTypeName ?? "Class").toUpperCase(),
                          style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${session.endTime.difference(session.startTime).inMinutes} min",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      if (isAlreadyBooked) ...[
                        const SizedBox(width: 8),
                         const Text(
                           "BOOKED",
                           style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                         ),
                      ] else if (isFull) ...[
                        const SizedBox(width: 8),
                         const Text(
                           "Waitlist Only",
                           style: TextStyle(color: AppTheme.errorColor, fontSize: 10, fontWeight: FontWeight.bold),
                         ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.sessionName.isNotEmpty ? session.sessionName : (session.classTypeName ?? "Session"), 
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(
                         radius: 10,
                         backgroundColor: Colors.grey.shade800,
                         child: Text((session.coachName != null && session.coachName!.isNotEmpty) ? session.coachName![0] : "C", style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        session.coachName ?? "Unknown Coach",
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      )
                    ],
                  )
                ],
              ),
            ),
            Container(
               child: isFull 
                 ? Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                      child: const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                    )
                 : (_isMember ? Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.primaryColor : (isAlreadyBooked ? AppTheme.primaryColor.withOpacity(0.2) : Colors.transparent),
                        border: Border.all(color:  isSelected ? AppTheme.primaryColor : Colors.grey.shade600, width: 2),
                      ),
                      child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.black) : (isAlreadyBooked ? const Icon(Icons.check, size: 14, color: AppTheme.primaryColor) : null),
                    ) : const SizedBox()),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
     return const Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No sessions available", style: TextStyle(color: Colors.grey)),
         ],
       ),
     );
  }

  Widget _buildBookingBottomBar() {
     return Container(
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
       ),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text("Selected Session", style: TextStyle(color: Colors.grey, fontSize: 12)),
                   const SizedBox(height: 4),
                   Text(
                     "${_selectedSessionEntity?.classTypeName} • ${DateFormat('hh:mm a').format(_selectedSessionEntity!.startTime)}",
                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                 ],
               ),
               const Text("1 Credit", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
             ],
           ),
           const SizedBox(height: 20),
           SizedBox(
             width: double.infinity,
             height: 56,
             child: ElevatedButton(
               style: AppTheme.primaryButtonStyle.copyWith(
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
               ),
               onPressed: _handleBooking,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: const [
                   Text("Confirm Booking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(width: 8),
                   Icon(Icons.arrow_forward)
                 ],
               ),
             ),
           )
         ],
       ),
     );
  }

  void _handleBooking() {
     if (!_isMember) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Only members can book sessions"), backgroundColor: Colors.orange));
        return;
     }

     if (_selectedSessionIdForBooking == null || _currentMemberId == null) {
        if (_currentMemberId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Member profile not found"), backgroundColor: Colors.red));
        }
        return;
     }

     print("SessionListPage: Booking Session ID: $_selectedSessionIdForBooking");
     print("SessionListPage: Current User ID: $_userId");
     print("SessionListPage: Resolved Member ID: $_currentMemberId");

     final bookingData = CreateBookingModel(
       memberId: _currentMemberId!,
       sessionId: _selectedSessionIdForBooking!,
       bookingTime: _selectedSessionEntity!.startTime,
       status: 0 // 0 = Confirmed, 1 = Cancelled
     );

     // Fix: Call createBookingAction, don't call UseCase directly
     context.read<BookingCubit>().createBookingAction(bookingData);
     // Note: Removed setState and immediate SnackBar here. 
     // The BlocListener in build() or _buildBookingBottomBar() should handle success/failure feedback.
  }

  // RBAC Management Methods

  void _showManagementOptions(SessionEntity session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
            title: const Text('Edit Session', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showSessionDialog(session: session);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppTheme.errorColor),
            title: const Text('Delete Session', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(session);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _confirmDelete(SessionEntity session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Delete Session', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${session.sessionName.isNotEmpty ? session.sessionName : session.classTypeName}"?', 
          style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              context.read<SessionCubit>().deleteSessionAction(session.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting session...'), backgroundColor: AppTheme.primaryColor),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSessionDialog({SessionEntity? session}) {
    final isEditing = session != null;
    final formKey = GlobalKey<FormState>();
    
    final nameController = TextEditingController(text: isEditing ? session.sessionName : "");
    final descriptionController = TextEditingController(text: isEditing ? session.description : "");
    final capacityController = TextEditingController(text: isEditing ? session.capacity.toString() : "20");
    final durationController = TextEditingController(
      text: isEditing ? session.endTime.difference(session.startTime).inMinutes.toString() : "60"
    );
    
    int? selectedCoachId = isEditing ? session.coachId : null;
    int? selectedClassTypeId = isEditing ? session.classTypeId : _selectedClassTypeId;
    DateTime sessionDate = isEditing ? session.startTime : _selectedDate;
    TimeOfDay sessionTime = isEditing ? TimeOfDay.fromDateTime(session.startTime) : const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              title: Text(isEditing ? 'Edit Session' : 'Add New Session', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Session Name', labelStyle: TextStyle(color: Colors.grey)),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      BlocBuilder<ClassTypeCubit, ClassTypeState>(
                        builder: (context, state) {
                          if (state is ClassTypesLoaded) {
                            return DropdownButtonFormField<int>(
                              value: selectedClassTypeId,
                              dropdownColor: AppTheme.cardBackground,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Class Type'),
                              items: state.classTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name!))).toList(),
                              onChanged: (v) => setDialogState(() => selectedClassTypeId = v),
                              validator: (v) => v == null ? 'Required' : null,
                            );
                          }
                          return const Text('Loading class types...');
                        },
                      ),
                      BlocBuilder<CoachCubit, CoachState>(
                        builder: (context, state) {
                          if (state is CoachesLoaded) {
                            return DropdownButtonFormField<int>(
                              value: selectedCoachId,
                              dropdownColor: AppTheme.cardBackground,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Coach'),
                              items: state.coaches.map((c) => DropdownMenuItem(value: c.id, child: Text(c.userName))).toList(),
                              onChanged: (v) => setDialogState(() => selectedCoachId = v),
                              validator: (v) => v == null ? 'Required' : null,
                            );
                          }
                          return const Text('Loading coaches...');
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Date: ${DateFormat('yyyy-MM-dd').format(sessionDate)}", style: const TextStyle(color: Colors.white70)),
                        trailing: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: sessionDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setDialogState(() => sessionDate = picked);
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Time: ${sessionTime.format(context)}", style: const TextStyle(color: Colors.white70)),
                        trailing: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: sessionTime);
                          if (picked != null) setDialogState(() => sessionTime = picked);
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: durationController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Duration (min)'),
                              validator: (v) => int.tryParse(v ?? "") == null ? 'Invalid' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: capacityController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Capacity'),
                              validator: (v) => int.tryParse(v ?? "") == null ? 'Invalid' : null,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: descriptionController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Description (Optional)'),
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
                    if (formKey.currentState!.validate()) {
                      final start = DateTime(
                        sessionDate.year, sessionDate.month, sessionDate.day,
                        sessionTime.hour, sessionTime.minute
                      );
                      final duration = int.parse(durationController.text);
                      final end = start.add(Duration(minutes: duration));
                      
                      if (isEditing) {
                        final update = UpdateSessionModel(
                          sessionName: nameController.text,
                          startTime: start,
                          endTime: end,
                          capacity: int.parse(capacityController.text),
                          description: descriptionController.text,
                        );
                        context.read<SessionCubit>().updateSessionAction(session.id, update);
                      } else {
                        final create = CreateSessionModel(
                          sessionName: nameController.text,
                          coachId: selectedCoachId!,
                          classTypeId: selectedClassTypeId!,
                          startTime: start,
                          endTime: end,
                          capacity: int.parse(capacityController.text),
                          description: descriptionController.text,
                        );
                        context.read<SessionCubit>().createSessionAction(create);
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Updating...' : 'Creating...'), backgroundColor: AppTheme.primaryColor),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
