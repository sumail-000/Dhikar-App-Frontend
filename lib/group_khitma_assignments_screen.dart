import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'language_provider.dart';

class GroupKhitmaAssignmentsScreen extends StatefulWidget {
  final int? groupId;
  final String? groupName;

  const GroupKhitmaAssignmentsScreen({
    super.key,
    this.groupId,
    this.groupName,
  });

  @override
  State<GroupKhitmaAssignmentsScreen> createState() =>
      _GroupKhitmaAssignmentsScreenState();
}

class _GroupKhitmaAssignmentsScreenState
    extends State<GroupKhitmaAssignmentsScreen> {
  String _selectedStatus = 'Not Completed';
  final List<String> _statusOptions = [
    'Not Completed',
    'Completed',
    'Pages Read'
  ];

  // Dummy data for demonstration
  final List<Map<String, dynamic>> _dummyMembers = [
    {
      'name': 'Ali Shahwarz (You)',
      'juz': '01 & 02',
      'status': 'Completed',
      'statusType': 'completed'
    },
    {
      'name': 'Zakria',
      'juz': '03 & 04',
      'status': '10 Pages Read',
      'statusType': 'pages_read'
    },
    {
      'name': 'Aon Abbas',
      'juz': '05 & 06',
      'status': 'Not Completed',
      'statusType': 'not_completed'
    },
    {
      'name': 'Fakhar Abid',
      'juz': '07 & 08',
      'status': 'Completed',
      'statusType': 'completed'
    },
    {
      'name': 'Waqas Ahmed',
      'juz': '09 & 10',
      'status': 'Not Completed',
      'statusType': 'not_completed'
    },
    {
      'name': 'Binyamin',
      'juz': '11 & 12',
      'status': 'Completed',
      'statusType': 'completed'
    },
    {
      'name': 'Abdullah',
      'juz': '13 & 14',
      'status': '10 Pages Read',
      'statusType': 'pages_read'
    },
    {
      'name': 'Saba Iqbal',
      'juz': '15 & 16',
      'status': 'Completed',
      'statusType': 'completed'
    },
    {
      'name': 'Hamna Tanvir',
      'juz': '17 & 18',
      'status': 'Completed',
      'statusType': 'completed'
    },
    {
      'name': 'Rabia Mushtaq',
      'juz': '19 & 20',
      'status': 'Not Completed',
      'statusType': 'not_completed'
    },
    {
      'name': 'Ayesha Ali',
      'juz': '21 & 22',
      'status': 'Completed',
      'statusType': 'completed'
    },
    {
      'name': 'Maryam Sadiq',
      'juz': '23 & 24',
      'status': 'Not Completed',
      'statusType': 'not_completed'
    },
    {
      'name': 'Usama',
      'juz': '25 & 26',
      'status': 'Completed',
      'statusType': 'completed'
    },
    {
      'name': 'Junaid Abbas',
      'juz': '27 & 28',
      'status': '10 Pages Read',
      'statusType': 'pages_read'
    },
    {
      'name': 'Farhad Ali',
      'juz': '29 & 30',
      'status': 'Completed',
      'statusType': 'completed'
    },
  ];

  Color _getStatusColor(String statusType) {
    switch (statusType) {
      case 'completed':
        return const Color(0xFFC2AEEA);
      case 'pages_read':
        return const Color(0xFFD4D400);
      case 'not_completed':
        return const Color(0xFFE65A5A);
      default:
        return const Color(0xFFC2AEEA);
    }
  }

  void _saveStatus() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Provider.of<LanguageProvider>(context, listen: false).isArabic
              ? 'تم حفظ الحالة بنجاح'
              : 'Status saved successfully',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final isArabic = languageProvider.isArabic;
        final textColor = isDarkMode ? Colors.white : const Color(0xFF2E7D32);

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.gradientColors,
                ),
              ),
              child: Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: Opacity(
                      opacity: isDarkMode ? 0.5 : 1.0,
                      child: Image.asset(
                        'assets/background_elements/3_background.png',
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Header - Compact version
                        Container(
                          height: 50, // Reduced from 70 to 50
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Stack(
                            children: [
                              // Back Arrow - Compact positioning
                              Positioned(
                                left: 4,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    padding: const EdgeInsets.all(4), // Reduced padding
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    icon: Icon(
                                      isArabic
                                          ? Icons.arrow_forward_ios
                                          : Icons.arrow_back_ios,
                                      color: textColor,
                                      size: 20, // Slightly smaller
                                    ),
                                  ),
                                ),
                              ),
                              // Title - Centered and compact
                              Center(
                                child: Text(
                                  isArabic
                                      ? 'تفاصيل ختمة المجموعة'
                                      : 'Group Khitma Details',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18, // Reduced from 22 to 18
                                    height: 1.1,
                                    letterSpacing: 0,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Table Headers - Compact version
                        Container(
                          margin: const EdgeInsets.only(top: 8), // Much reduced spacing
                          height: 20, // Reduced from 22
                          padding: const EdgeInsets.symmetric(horizontal: 12), // Consistent padding
                          child: Row(
                            children: [
                              // Member Name Header - More flexible width
                              Expanded(
                                flex: 4,
                                child: Text(
                                  isArabic ? 'اسم العضو' : 'Member Name',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14, // Reduced from 16
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFFC2AEEA),
                                  ),
                                ),
                              ),
                              // Assigned Juz Header
                              Expanded(
                                flex: 2,
                                child: Text(
                                  isArabic ? 'الجزء المعين' : 'Assigned Juz',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14, // Reduced from 16
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFFC2AEEA),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              // Juz Status Header
                              Expanded(
                                flex: 3,
                                child: Text(
                                  isArabic ? 'حالة الجزء' : 'Juz Status',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14, // Reduced from 16
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFFC2AEEA),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Members List - Compact version
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 4), // Much reduced spacing
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12), // Consistent padding
                              itemCount: _dummyMembers.length,
                              itemBuilder: (context, index) {
                                final member = _dummyMembers[index];
                                return Container(
                                  height: 28, // Much more compact - reduced from 38 to 28
                                  margin: const EdgeInsets.only(bottom: 2), // Minimal spacing between items
                                  child: Row(
                                    children: [
                                      // Member Name - Flexible width
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          member['name'],
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 13, // Reduced from 16 to 13
                                            height: 1.2,
                                            letterSpacing: 0,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Assigned Juz - Compact spacing
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          member['juz'],
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 13, // Reduced from 16 to 13
                                            height: 1.2,
                                            letterSpacing: 0,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // Juz Status - Compact status badge
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 20, // Reduced from 22 to 20
                                            constraints: const BoxConstraints(
                                              minWidth: 60,
                                              maxWidth: 100,
                                            ),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(member['statusType']),
                                              borderRadius: BorderRadius.circular(3), // Slightly smaller radius
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            child: Text(
                                              member['status'],
                                              style: TextStyle(
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w500,
                                                fontSize: 11, // Much smaller for compact look
                                                height: 1.0,
                                                letterSpacing: 0,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Bottom Section with Update Status - Compact version
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Update Your Juz Status Label - Compact version
                              Container(
                                height: 24, // Reduced from 30 to 24
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC2AEEA),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  isArabic ? 'تحديث حالة الجزء' : 'Update Your Juz Status',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16, // Reduced from 22 to 16
                                    height: 1.0,
                                    letterSpacing: 0,
                                    color: const Color(0xFF2D1B69),
                                  ),
                                ),
                              ),

                              // Status Dropdown - Compact version
                              Container(
                                height: 40, // Reduced from 56 to 40
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFCCCCCC),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6), // Reduced radius
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedStatus,
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14, // Reduced from 16 to 14
                                      color: Colors.white,
                                    ),
                                    dropdownColor: isDarkMode
                                        ? const Color(0xFF2D1B69)
                                        : Colors.white,
                                    items: _statusOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          isArabic 
                                              ? (value == 'Completed' ? 'مكتمل' : 
                                                 value == 'Not Completed' ? 'غير مكتمل' : 
                                                 'صفحات مقروءة')
                                              : value,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedStatus = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),

                              // Save Button - Compact version
                              Container(
                                height: 36, // Reduced from 56 to 36
                                child: ElevatedButton(
                                  onPressed: _saveStatus,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF2EDE0),
                                    foregroundColor: const Color(0xFF2D1B69),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18), // Proportional to height
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: Text(
                                    isArabic ? 'حفظ' : 'Save',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14, // Reduced from 18 to 14
                                      color: const Color(0xFF2D1B69),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8), // Reduced bottom spacing
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
