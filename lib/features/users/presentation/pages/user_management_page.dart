import 'package:flutter/material.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/core/role_helper.dart';
import 'package:thesavage/features/users/data/datasource/user_api_service.dart';
import 'package:thesavage/features/users/domain/entities/user_entity.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final UserApiService _apiService = UserApiService();
  List<UserEntity> _users = [];
  bool _isLoading = true;
  String? _error;
  String _currentUserRole = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _currentUserRole = await RoleHelper.getCurrentUserRole();
      
      // Check if user is Admin
      if (_currentUserRole.toLowerCase() != 'admin') {
        setState(() {
          _error = 'Access Denied: Admin privileges required';
          _isLoading = false;
        });
        return;
      }

      final users = await _apiService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changeUserRole(UserEntity user, String newRole) async {
    if (newRole == user.role) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Role Change', style: AppTheme.heading3),
        content: Text(
          'Change ${user.userName}\'s role from ${user.role} to $newRole?',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppTheme.primaryButtonStyle,
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.changeUserRole(user.userName, newRole);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Role changed successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Reload data
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _deleteUser(UserEntity user) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete', style: AppTheme.heading3),
        content: Text(
          'Are you sure you want to delete user "${user.userName}"?\n\nThis action cannot be undone.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.deleteUser(user.userName);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${user.userName} deleted successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Reload data
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('User Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // Transparent for dark theme
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(_currentUserRole.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primaryColor, // Primary color for admin chip
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.errorColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: AppTheme.primaryButtonStyle,
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Text('No users found', style: AppTheme.heading3.copyWith(color: AppTheme.textLight)),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppTheme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingMD),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _UserCard(
                            user: user,
                            onRoleChanged: (newRole) => _changeUserRole(user, newRole),
                            onDelete: () => _deleteUser(user),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserEntity user;
  final Function(String) onRoleChanged;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onRoleChanged,
    required this.onDelete,
  });

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppTheme.errorColor; // Red
      case 'coach':
        return AppTheme.infoColor;  // Blue
      case 'member':
        return AppTheme.successColor; // Green
      case 'client':
        return Colors.purple; // Purple for Client
      default:
        return AppTheme.textLight;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.verified_user_rounded;
      case 'coach':
        return Icons.sports_gymnastics_rounded;
      case 'member':
        return Icons.person_rounded;
      case 'client':
        return Icons.account_circle_rounded;
      default:
        return Icons.person_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRoleIcon(user.role),
                    color: _getRoleColor(user.role),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        '@${user.userName}',
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
                  onPressed: onDelete,
                  tooltip: 'Delete User',
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMD),
            _buildInfoRow(Icons.email_outlined, user.email),
            if (user.phoneNumber != null) ...[
              const SizedBox(height: AppTheme.spacingXS),
              _buildInfoRow(Icons.phone_outlined, user.phoneNumber!),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
              child: Divider(color: Colors.white10), // Light divider
            ),
            Row(
              children: [
                Text(
                  'Role Permissions',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: user.role,
                        isExpanded: true,
                        dropdownColor: AppTheme.cardBackground, // Dark dropdown
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                        elevation: 2,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        items: () {
                          final roles = ['Admin', 'Coach', 'Member', 'Client'];
                          if (!roles.contains(user.role)) {
                            roles.add(user.role);
                          }
                          return roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Row(
                                children: [
                                  Icon(
                                    _getRoleIcon(role),
                                    size: 18,
                                    color: _getRoleColor(role),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    role,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: role == user.role ? AppTheme.primaryColor : Colors.white,
                                      fontWeight: role == user.role ? FontWeight.bold : FontWeight.normal
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList();
                        }(),

                        onChanged: (newRole) {
                          if (newRole != null) {
                            onRoleChanged(newRole);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
