import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thesavage/core/role_helper.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/attendance/data/models/create_attendance_model.dart';
import 'package:thesavage/features/attendance/domain/entities/attendance_entity.dart';
import 'package:thesavage/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:thesavage/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_state.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_state.dart';
import 'package:thesavage/features/memberpro/domain/entities/member_profile_entity.dart';
import 'package:thesavage/features/bookings/domain/entities/booking_entity.dart';
import 'package:thesavage/features/bookings/presentation/bloc/booking_cubit.dart';
import 'package:thesavage/features/bookings/presentation/bloc/booking_state.dart';
import '../../data/models/update_attendance_model.dart';

class AttendanceListPage extends StatefulWidget {
  const AttendanceListPage({super.key});

  @override
  State<AttendanceListPage> createState() => _AttendanceListPageState();
}

class _AttendanceListPageState extends State<AttendanceListPage> {
  bool canManage = false;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedSessionId;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
    context.read<AttendanceCubit>().loadAttendances();
    context.read<SessionCubit>().loadSessions();
    context.read<MemberCubit>().loadMembers();
    context.read<BookingCubit>().loadBookings();
  }

  Future<void> _checkPermissions() async {
    final canManageAttendance = await RoleHelper.canManageAttendance();
    setState(() {
      canManage = canManageAttendance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.primaryColor),
          );
        } else if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSessionSelector(),
              _buildActionArea(),
              Expanded(
                child: _buildAttendanceList(),
              ),
            ],
          ),
        ),
        floatingActionButton: canManage && _selectedSessionId != null
            ? FloatingActionButton.extended(
                onPressed: () => _showAddAttendanceDialog(context),
                backgroundColor: AppTheme.primaryColor,
                icon: const Icon(Icons.person_add_alt_1, color: Colors.black),
                label: const Text("Manual Mark", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            : null,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              shape: const CircleBorder(),
            ),
          ),
          Text("Attendance", style: AppTheme.heading3),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildSessionSelector() {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is SessionsLoaded) {
          return Container(
            height: 100,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.sessions.length,
              itemBuilder: (context, index) {
                final session = state.sessions[index];
                final isSelected = _selectedSessionId == session.id;
                final isFull = session.bookingsCount >= session.capacity;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSessionId = session.id;
                    });
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFull 
                        ? AppTheme.errorColor.withOpacity(0.1) 
                        : (isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isFull 
                          ? AppTheme.errorColor 
                          : (isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.05)),
                        width: (isSelected || isFull) ? 2 : 1,
                      ),
                      boxShadow: isFull 
                        ? [BoxShadow(color: AppTheme.errorColor.withOpacity(0.1), blurRadius: 10)]
                        : (isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 10)] : null),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.sessionName.isNotEmpty ? session.sessionName : "Session #${session.id}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: isSelected ? Colors.black.withOpacity(0.7) : Colors.grey,
                            fontSize: 12,
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
        return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildActionArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() {}),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Search member...",
            hintStyle: TextStyle(color: Colors.grey.shade600),
            icon: Icon(Icons.search, color: Colors.grey.shade500),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_selectedSessionId == null) {
      return const Center(child: Text("Please select a session to view attendance", style: TextStyle(color: Colors.grey)));
    }

    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, attendanceState) {
        return BlocBuilder<BookingCubit, BookingState>(
          builder: (context, bookingState) {
            return BlocBuilder<MemberCubit, MemberState>(
              builder: (context, memberState) {
                if (attendanceState is AttendanceLoading || bookingState is BookingLoading || memberState is MemberLoading) {
                   return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                }

                if (attendanceState is AttendancesLoaded && memberState is MembersLoaded) {
                   List<MemberProfileEntity> allMembers = memberState.members;
                   
                   // Resolve selected session bookings
                   List<BookingEntity> sessionBookings = [];
                   final sessionState = context.read<SessionCubit>().state;
                   
                   // Logic to extract bookings for selected session
                   if (sessionState is SessionsLoaded) {
                     try {
                        final session = sessionState.sessions.firstWhere((s) => s.id == _selectedSessionId);
                        sessionBookings = session.bookings.where((b) => b.status != 'Cancelled').toList();
                        
                         if (sessionBookings.isEmpty && bookingState is BookingsLoaded) {
                           sessionBookings = bookingState.bookings.where((b) => b.sessionId == _selectedSessionId && b.status != 'Cancelled').toList();
                         }
                     } catch (_) {
                        if (bookingState is BookingsLoaded) {
                           sessionBookings = bookingState.bookings.where((b) => b.sessionId == _selectedSessionId && b.status != 'Cancelled').toList();
                        }
                     }
                   } else if (bookingState is BookingsLoaded) {
                       sessionBookings = bookingState.bookings.where((b) => b.sessionId == _selectedSessionId && b.status != 'Cancelled').toList();
                   }

                  final sessionAttendances = attendanceState.attendances.where((a) => a.sessionId == _selectedSessionId).toList();

                  // Merge logic
                  final Map<int, AttendanceEntity> displayMap = {};

                  String resolveName(int memberId, String fallback) {
                    try {
                      final m = allMembers.firstWhere((m) => m.id == memberId);
                      if (m.firstName != null && m.firstName!.isNotEmpty) {
                        return "${m.firstName} ${m.lastName ?? ''}".trim();
                      }
                      return m.userName;
                    } catch (_) {
                      return fallback;
                    }
                  }

                  // Add bookings placeholders
                  for (var b in sessionBookings) {
                    displayMap[b.memberId] = AttendanceEntity(
                      id: -1, 
                      sessionId: _selectedSessionId!, 
                      sessionName: b.sessionName, 
                      memberId: b.memberId, 
                      memberName: resolveName(b.memberId, b.memberName), 
                      status: "Not Marked",
                    );
                  }

                  // Override with actual attendance
                  for (var a in sessionAttendances) {
                     displayMap[a.memberId] = AttendanceEntity(
                       id: a.id,
                       sessionId: a.sessionId,
                       sessionName: a.sessionName,
                       memberId: a.memberId,
                       memberName: resolveName(a.memberId, a.memberName),
                       status: a.status,
                     );
                  }

                  if (displayMap.isEmpty) {
                    return const Center(child: Text("No members found for this session.", style: TextStyle(color: Colors.grey)));
                  }

                  final query = _searchController.text.toLowerCase();
                  final displayList = displayMap.values.where((u) => u.memberName.toLowerCase().contains(query)).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final attendance = displayList[index];
                      return _buildAttendanceRow(attendance);
                    },
                  );
                }

                if (attendanceState is AttendanceError) return Center(child: Text("Error: ${attendanceState.message}", style: const TextStyle(color: Colors.red)));
                
                return const Center(child: Text("Preparing list...", style: TextStyle(color: Colors.grey)));
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceRow(AttendanceEntity attendance) {
    // Status Logic per Backend Enum or String: "0"/"Present" = Present, "1"/"Absent" = Absent
    final status = attendance.status;
    bool isPresent = status == "0" || status == "Present";
    bool isAbsent = status == "1" || status == "Absent";
    bool isNotMarked = attendance.id == -1;

    String statusText = isPresent ? "Present" : (isAbsent ? "Absent" : "Not Marked");
    Color statusColor = isPresent ? AppTheme.primaryColor : (isAbsent ? AppTheme.errorColor : Colors.grey);
    IconData statusIcon = isPresent ? Icons.check_circle : (isAbsent ? Icons.cancel : Icons.help_outline);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.memberName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isNotMarked ? "Mark attendance below" : statusText,
                  style: TextStyle(color: statusColor.withOpacity(0.7), fontSize: 12),
                )
              ],
            ),
          ),
          if (canManage)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAttendanceAction(
                icon: Icons.check, 
                color: AppTheme.primaryColor, 
                active: isPresent, 
                onTap: () => _toggleAttendance(attendance, "0"),
              ),
              const SizedBox(width: 8),
              _buildAttendanceAction(
                icon: Icons.close, 
                color: AppTheme.errorColor, 
                active: isAbsent, 
                onTap: () => _toggleAttendance(attendance, "1"),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAttendanceAction({required IconData icon, required Color color, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? color : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: active ? Colors.black : color, size: 20),
      ),
    );
  }

  void _toggleAttendance(AttendanceEntity attendance, String newStatus) {
    if (attendance.id == -1) {
      // Create new
       context.read<AttendanceCubit>().createAttendanceAction(
        CreateAttendanceModel(
          sessionId: attendance.sessionId, 
          memberId: attendance.memberId, 
          status: int.parse(newStatus),
        ),
      );
    } else {
      // Update
      context.read<AttendanceCubit>().updateAttendanceAction(
        attendance.id, 
        UpdateAttendanceModel(status: int.parse(newStatus)),
      );
    }
  }

  void _showAddAttendanceDialog(BuildContext context) {
    // Keep manual mark dialog as fallback or for unbooked users
    final formKey = GlobalKey<FormState>();
    int? selectedMemberId;
    int selectedStatus = 0;

    final membersState = context.read<MemberCubit>().state;
    List<dynamic> members = [];
    if (membersState is MembersLoaded) members = membersState.members;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Manual Mark Attendance', style: TextStyle(color: Colors.white)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      dropdownColor: AppTheme.cardBackground,
                       style: const TextStyle(color: Colors.white),
                      decoration: _dialogInputDeco("Select Member"),
                      items: members.map<DropdownMenuItem<int>>((member) {
                        return DropdownMenuItem<int>(
                          value: member.id,
                          child: Text(member.userName),
                        );
                      }).toList(),
                      onChanged: (value) => selectedMemberId = value,
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      dropdownColor: AppTheme.cardBackground,
                      style: const TextStyle(color: Colors.white),
                      value: selectedStatus,
                      decoration: _dialogInputDeco("Status"),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text("Present")),
                        DropdownMenuItem(value: 1, child: Text("Absent")),
                      ],
                      onChanged: (value) => setDialogState(() => selectedStatus = value!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() && selectedMemberId != null && _selectedSessionId != null) {
                      context.read<AttendanceCubit>().createAttendanceAction(
                        CreateAttendanceModel(sessionId: _selectedSessionId!, memberId: selectedMemberId!, status: selectedStatus),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Save', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogInputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor)),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Record', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to remove this record?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
             onPressed: () {
               context.read<AttendanceCubit>().deleteAttendanceAction(id);
               Navigator.pop(context);
             }, 
             style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
             child: const Text('Delete')
          ),
        ],
      ),
    );
  }
}


