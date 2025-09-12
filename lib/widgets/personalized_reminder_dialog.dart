import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../services/api_client.dart';

class PersonalizedReminderDialog extends StatefulWidget {
  final String memberName;
  final int memberId;
  final int groupId;
  final String groupName;
  final bool isDhikr;

  const PersonalizedReminderDialog({
    super.key,
    required this.memberName,
    required this.memberId,
    required this.groupId,
    required this.groupName,
    required this.isDhikr,
  });

  @override
  State<PersonalizedReminderDialog> createState() => _PersonalizedReminderDialogState();

  static Future<bool?> show({
    required BuildContext context,
    required String memberName,
    required int memberId,
    required int groupId,
    required String groupName,
    required bool isDhikr,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PersonalizedReminderDialog(
        memberName: memberName,
        memberId: memberId,
        groupId: groupId,
        groupName: groupName,
        isDhikr: isDhikr,
      ),
    );
  }
}

class _PersonalizedReminderDialogState extends State<PersonalizedReminderDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  bool _useCustomMessage = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendReminder() async {
    setState(() => _isLoading = true);

    try {
      final message = _useCustomMessage ? _messageController.text.trim() : '';
      
      final resp = widget.isDhikr
          ? await ApiClient.instance.sendDhikrGroupMemberReminder(
              widget.groupId, 
              widget.memberId, 
              message,
            )
          : await ApiClient.instance.sendGroupMemberReminder(
              widget.groupId, 
              widget.memberId, 
              message,
            );

      if (resp.ok) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personalized reminder sent to user'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resp.error ?? 'Failed to send reminder'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending reminder: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode 
              ? const Color(0xFF1F1F1F)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode 
                      ? Colors.blue.shade700.withOpacity(0.2)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: themeProvider.isDarkMode 
                      ? Colors.blue.shade300
                      : Colors.blue.shade700,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Send Reminder',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: themeProvider.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'to ${widget.memberName}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: themeProvider.primaryTextColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Explanation card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode 
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'This will send a personalized message starting with "Salam ${widget.memberName.split(' ').first}!"',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: themeProvider.primaryTextColor.withOpacity(0.7),
                    height: 1.2,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Custom message toggle
              InkWell(
                onTap: () => setState(() => _useCustomMessage = !_useCustomMessage),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeProvider.borderColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _useCustomMessage 
                                ? (themeProvider.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700)
                                : themeProvider.borderColor,
                            width: 2,
                          ),
                          color: _useCustomMessage 
                              ? (themeProvider.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700)
                              : Colors.transparent,
                        ),
                        child: _useCustomMessage
                            ? const Icon(Icons.check, size: 8, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add custom message',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: themeProvider.primaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Custom message field
              if (_useCustomMessage) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode 
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeProvider.isDarkMode 
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 2,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: themeProvider.primaryTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your custom message...',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 12,
                        color: themeProvider.primaryTextColor.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your message will be added after the "Salam ${widget.memberName.split(' ').first}!" greeting.',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: themeProvider.primaryTextColor.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
            ),
          ),
          
          actions: [
            // Cancel button
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: themeProvider.primaryTextColor.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(width: 6),
            
            // Send button
            ElevatedButton(
              onPressed: _isLoading ? null : _sendReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode 
                    ? const Color(0xFF4A90E2)
                    : const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.send, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Send Reminder',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
