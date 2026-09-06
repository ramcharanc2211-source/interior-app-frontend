import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  final dynamic designer;

  const BookingScreen({super.key, required this.designer});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ============================================================
  // API
  // ============================================================

  static const String baseUrl = 'http://127.0.0.1:5000';

  // ============================================================
  // DATE
  // ============================================================

  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();

  // ============================================================
  // TIME
  // ============================================================

  String selectedTime = '';

  List<String> bookedSlots = [];

  bool isLoadingSlots = false;
  bool isBooking = false;

  // ============================================================
  // TIME SLOTS
  // ============================================================

  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBookedSlots();
    });
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // DESIGNER IMAGE
  // ============================================================

  String getDesignerImage() {
    final image = widget.designer['image'];

    if (image != null && image.toString().trim().isNotEmpty) {
      return image.toString();
    }

    return 'https://images.unsplash.com/'
        'photo-1618221195710-dd6b41faaea6?w=1200';
  }

  // ============================================================
  // DESIGNER NAME
  // ============================================================

  String getDesignerName() {
    final name = widget.designer['name'];

    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString();
    }

    return 'Interior Designer';
  }

  // ============================================================
  // DESIGNER SPECIALTY
  // ============================================================

  String getSpecialty() {
    final specialty = widget.designer['specialty'];

    if (specialty != null && specialty.toString().trim().isNotEmpty) {
      return specialty.toString();
    }

    return 'Interior Design';
  }

  // ============================================================
  // FETCH BOOKED SLOTS
  // ============================================================

  Future<void> fetchBookedSlots() async {
    if (!mounted) return;

    setState(() {
      isLoadingSlots = true;
      bookedSlots = [];
    });

    try {
      // ----------------------------------------------------------
      // GET SAVED JWT
      // ----------------------------------------------------------

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        debugPrint('JWT token not found');

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Please login again.')));
        }

        return;
      }

      // ----------------------------------------------------------
      // DESIGNER ID
      // ----------------------------------------------------------

      final designerId = widget.designer['_id'];

      if (designerId == null || designerId.toString().isEmpty) {
        debugPrint('Designer ID not found');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Designer information is missing.')),
          );
        }

        return;
      }

      // ----------------------------------------------------------
      // DATE
      // ----------------------------------------------------------

      final formattedDate = formatDate(selectedDate);

      // ----------------------------------------------------------
      // REQUEST
      // ----------------------------------------------------------

      final uri = Uri.parse('$baseUrl/api/bookings/by-date').replace(
        queryParameters: {
          'date': formattedDate,
          'designerId': designerId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('Booked slots response: ${response.statusCode}');

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          final slots = data
              .where((booking) => booking is Map && booking['time'] != null)
              .map<String>((booking) => booking['time'].toString())
              .toList();

          if (mounted) {
            setState(() {
              bookedSlots = slots;
            });
          }
        }
      }
      // ----------------------------------------------------------
      // UNAUTHORIZED
      // ----------------------------------------------------------
      else if (response.statusCode == 401) {
        debugPrint('JWT expired or invalid');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your session expired. Please login again.'),
            ),
          );
        }
      }
      // ----------------------------------------------------------
      // OTHER ERROR
      // ----------------------------------------------------------
      else {
        debugPrint(
          'Failed to fetch booked slots: '
          '${response.statusCode}',
        );

        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Fetch booked slots error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not load booked slots. Please check the server.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSlots = false;
        });
      }
    }
  }

  // ============================================================
  // YEAR SELECTOR
  // ============================================================

  Future<void> selectYear() async {
    final currentYear = DateTime.now().year;

    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Select Year',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 350,
            height: 360,
            child: GridView.builder(
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                final year = currentYear + index;

                final isSelected = focusedDay.year == year;

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(context, year);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear == null || !mounted) {
      return;
    }

    final now = DateTime.now();

    DateTime newDate = DateTime(selectedYear, focusedDay.month, 1);

    if (selectedYear == now.year &&
        newDate.isBefore(DateTime(now.year, now.month, now.day))) {
      newDate = DateTime(now.year, now.month, now.day);
    }

    setState(() {
      focusedDay = newDate;
      selectedDate = newDate;
      selectedTime = '';
    });

    fetchBookedSlots();
  }

  // ============================================================
  // CHANGE MONTH
  // ============================================================

  void changeMonth(int amount) {
    final newFocusedDay = DateTime(
      focusedDay.year,
      focusedDay.month + amount,
      1,
    );

    final firstAllowedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final firstAllowedMonth = DateTime(
      firstAllowedDate.year,
      firstAllowedDate.month,
      1,
    );

    if (newFocusedDay.isBefore(firstAllowedMonth)) {
      return;
    }

    if (newFocusedDay.year > 2035) {
      return;
    }

    setState(() {
      focusedDay = newFocusedDay;
    });
  }

  // ============================================================
  // BOOK NOW
  // ============================================================

  Future<void> bookNow() async {
    // ----------------------------------------------------------
    // TIME VALIDATION
    // ----------------------------------------------------------

    if (selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );

      return;
    }

    // ----------------------------------------------------------
    // LOCAL BOOKED SLOT CHECK
    // ----------------------------------------------------------

    if (bookedSlots.contains(selectedTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This time slot is already booked.')),
      );

      return;
    }

    setState(() {
      isBooking = true;
    });

    try {
      // --------------------------------------------------------
      // GET JWT
      // --------------------------------------------------------

      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your session is missing. Please login again.'),
            ),
          );
        }

        return;
      }

      // --------------------------------------------------------
      // DESIGNER ID
      // --------------------------------------------------------

      final designerId = widget.designer['_id'];

      if (designerId == null || designerId.toString().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Designer information is missing.')),
          );
        }

        return;
      }

      // --------------------------------------------------------
      // CREATE BOOKING
      // --------------------------------------------------------

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/bookings'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'designerId': designerId.toString(),
              'date': formatDate(selectedDate),
              'time': selectedTime,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('Booking response: ${response.statusCode}');

      debugPrint('Booking body: ${response.body}');

      if (!mounted) return;

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (response.statusCode == 201) {
        showBookingSuccess();
      }
      // --------------------------------------------------------
      // SLOT ALREADY BOOKED
      //
      // Backend currently returns 400.
      // --------------------------------------------------------
      else if (response.statusCode == 400) {
        String message = 'This slot is already booked.';

        try {
          final data = jsonDecode(response.body);

          if (data is Map && data['message'] != null) {
            message = data['message'].toString();
          }
        } catch (_) {}

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));

        await fetchBookedSlots();
      }
      // --------------------------------------------------------
      // UNAUTHORIZED
      // --------------------------------------------------------
      else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your session expired. Please login again.'),
          ),
        );
      }
      // --------------------------------------------------------
      // OTHER ERROR
      // --------------------------------------------------------
      else {
        String message = 'Booking failed. Please try again.';

        try {
          final data = jsonDecode(response.body);

          if (data is Map && data['message'] != null) {
            message = data['message'].toString();
          }
        } catch (_) {}

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      debugPrint('Booking error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to the server.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isBooking = false;
        });
      }
    }
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void showBookingSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 58,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Booking Confirmed!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Text(
                'Your consultation with '
                '${getDesignerName()} '
                'has been successfully booked.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF6A11CB),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDate(selectedDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF2575FC),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedTime,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A11CB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text(
          'Book Consultation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            ),
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // DESIGNER CARD
            // ======================================================
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      getDesignerImage(),
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 85,
                          height: 85,
                          color: Colors.white24,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getDesignerName(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          getSpecialty(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 9),

                        const Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '4.9 Rating',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ======================================================
            // SELECT DATE
            // ======================================================
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Choose a convenient date for your consultation.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // CALENDAR
            // ======================================================
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          changeMonth(-1);
                        },
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),

                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: selectYear,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A11CB).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: Color(0xFF6A11CB),
                                size: 20,
                              ),

                              const SizedBox(width: 7),

                              Text(
                                focusedDay.year.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF6A11CB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(width: 3),

                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF6A11CB),
                              ),
                            ],
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          changeMonth(1);
                        },
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),

                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: focusedDay,

                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      leftChevronVisible: false,
                      rightChevronVisible: false,
                      titleTextStyle: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,

                      todayDecoration: BoxDecoration(
                        color: Colors.orange.shade400,
                        shape: BoxShape.circle,
                      ),

                      selectedDecoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        ),
                        shape: BoxShape.circle,
                      ),

                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),

                      todayTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),

                      weekendTextStyle: TextStyle(color: Colors.grey.shade700),
                    ),

                    selectedDayPredicate: (day) {
                      return isSameDay(selectedDate, day);
                    },

                    onDaySelected: (selectedDay, newFocusedDay) {
                      setState(() {
                        selectedDate = selectedDay;
                        focusedDay = newFocusedDay;
                        selectedTime = '';
                      });

                      fetchBookedSlots();
                    },

                    onPageChanged: (newFocusedDay) {
                      setState(() {
                        focusedDay = newFocusedDay;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ======================================================
            // SELECTED DATE
            // ======================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6A11CB).withOpacity(0.10),
                    const Color(0xFF2575FC).withOpacity(0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        formatDate(selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ======================================================
            // TIME TITLE
            // ======================================================
            const Text(
              'Choose Time',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              'Available consultation time slots',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 18),

            // ======================================================
            // LOADING
            // ======================================================
            if (isLoadingSlots)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: CircularProgressIndicator(color: Color(0xFF6A11CB)),
                ),
              ),

            // ======================================================
            // TIME SLOTS
            // ======================================================
            if (!isLoadingSlots)
              Wrap(
                spacing: 10,
                runSpacing: 12,
                children: timeSlots.map((time) {
                  final isBooked = bookedSlots.contains(time);

                  final isSelected = selectedTime == time;

                  return GestureDetector(
                    onTap: isBooked
                        ? null
                        : () {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 115,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                              )
                            : null,
                        color: isBooked
                            ? Colors.grey.shade300
                            : isSelected
                            ? null
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isBooked
                              ? Colors.grey.shade400
                              : isSelected
                              ? Colors.transparent
                              : Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isBooked
                                ? Icons.block_rounded
                                : Icons.access_time_rounded,
                            size: 20,
                            color: isBooked
                                ? Colors.grey.shade600
                                : isSelected
                                ? Colors.white
                                : const Color(0xFF6A11CB),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            time,
                            style: TextStyle(
                              color: isBooked
                                  ? Colors.grey.shade600
                                  : isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            isBooked
                                ? 'Booked'
                                : isSelected
                                ? 'Selected'
                                : 'Available',
                            style: TextStyle(
                              fontSize: 11,
                              color: isBooked
                                  ? Colors.grey.shade600
                                  : isSelected
                                  ? Colors.white70
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),

            // ======================================================
            // BOOKING SUMMARY
            // ======================================================
            if (selectedTime.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _summaryRow(
                      Icons.person_outline_rounded,
                      'Designer',
                      getDesignerName(),
                    ),

                    const SizedBox(height: 10),

                    _summaryRow(
                      Icons.calendar_today_rounded,
                      'Date',
                      formatDate(selectedDate),
                    ),

                    const SizedBox(height: 10),

                    _summaryRow(
                      Icons.access_time_rounded,
                      'Time',
                      selectedTime,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // ======================================================
            // CONFIRM BOOKING
            // ======================================================
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isBooking ? null : bookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A11CB),
                  disabledBackgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isBooking
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'CONFIRM BOOKING',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                'You can change the date or time before confirming.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6A11CB)),

        const SizedBox(width: 10),

        Text('$title:', style: TextStyle(color: Colors.grey.shade600)),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
