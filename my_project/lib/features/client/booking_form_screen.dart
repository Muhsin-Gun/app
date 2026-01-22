import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/custom_image_widget.dart';
import '../../models/product_model.dart';
import '../../models/booking_model.dart';

class BookingFormScreen extends StatefulWidget {
  final ProductModel product;
  const BookingFormScreen({super.key, required this.product});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isLoading = false;
  String _paymentMethod = 'Cash'; // 'Cash' or 'M-Pesa'

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final bookingProvider = context.read<BookingProvider>();
      final paymentProvider = context.read<PaymentProvider>();

      final scheduledDateTime = _combineDateAndTime(
        _selectedDate,
        _selectedTime!,
      );

      // Handle M-Pesa payment if selected
      if (_paymentMethod == 'M-Pesa') {
        final paymentSuccess = await paymentProvider.processMpesaPayment(
          phoneNumber: _phoneController.text.trim(),
          amount: widget.product.price,
          reference: widget.product.title,
        );

        if (!paymentSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                paymentProvider.errorMessage ?? 'Payment initiation failed',
              ),
            ),
          );
          return;
        }
      }

      final booking = BookingModel(
        id: '',
        clientId: authProvider.userId!,
        productId: widget.product.id,
        status: 'pending',
        scheduledDate: scheduledDateTime,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        totalAmount: widget.product.price,
        clientName: authProvider.userName ?? 'Client',
        productTitle: widget.product.title,
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        statusHistory: ['pending'],
      );

      final success = await bookingProvider.createBooking(booking);
      if (success && mounted) {
        _showSuccessDialog();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    final timeParts = time.split(' ');
    final hourMin = timeParts[0].split(':');
    int hour = int.parse(hourMin[0]);
    int minute = int.parse(hourMin[1]);
    if (timeParts[1] == 'PM' && hour != 12) hour += 12;
    if (timeParts[1] == 'AM' && hour == 12) hour = 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 80,
              ).animate().scale(duration: 400.ms, curve: Curves.bounceOut),
              SizedBox(height: 3.h),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
              ),
              SizedBox(height: 1.h),
              Text(
                'Your professional will arrive on ${DateFormat('MMM dd').format(_selectedDate)} at $_selectedTime',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Great, thanks!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complete Booking',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomImageWidget(
                        imageUrl: widget.product.imageUrls.isNotEmpty
                            ? widget.product.imageUrls.first
                            : '',
                        width: 22.w,
                        height: 22.w,
                        fit: BoxFit.cover,
                        semanticLabel:
                            'Product image for ${widget.product.title}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            widget.product.category,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${widget.product.price}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              SizedBox(height: 4.h),
              const Text(
                'Pick a Date',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ).animate().fadeIn(delay: 100.ms),
              SizedBox(height: 2.h),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 14,
                  itemBuilder: (context, index) {
                    final date = DateTime.now().add(Duration(days: index + 1));
                    final isSelected = date.day == _selectedDate.day;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 200.ms),

              SizedBox(height: 4.h),
              const Text(
                'Available Time',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ).animate().fadeIn(delay: 300.ms),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _timeSlots.map((time) {
                  final isSelected = _selectedTime == time;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTime = time),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 400.ms),

              SizedBox(height: 4.h),
              const Text(
                'Address & Contact',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ).animate().fadeIn(delay: 500.ms),
              SizedBox(height: 2.h),
              _buildField(
                'Phone Number',
                _phoneController,
                Icons.phone_rounded,
              ),
              SizedBox(height: 16),
              _buildField(
                'Service Address',
                _addressController,
                Icons.location_on_rounded,
              ),
              SizedBox(height: 16),
              _buildField(
                'Instructions (Optional)',
                _notesController,
                Icons.notes_rounded,
                maxLines: 3,
              ),
              SizedBox(height: 4.h),
              const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ).animate().fadeIn(delay: 600.ms),
              SizedBox(height: 2.h),
              Row(
                children: [
                  _buildPaymentOption('Cash', Icons.payments_outlined, theme),
                  SizedBox(width: 4.w),
                  _buildPaymentOption(
                    'M-Pesa',
                    Icons.phone_android_rounded,
                    theme,
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Quote', style: TextStyle(fontSize: 12)),
                    Text(
                      '\$${widget.product.price}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 45.w,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Lock in Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (v) =>
          v!.isEmpty && label != 'Instructions (Optional)' ? 'Required' : null,
    );
  }

  Widget _buildPaymentOption(String method, IconData icon, ThemeData theme) {
    final isSelected = _paymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                method,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.colorScheme.primary : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
