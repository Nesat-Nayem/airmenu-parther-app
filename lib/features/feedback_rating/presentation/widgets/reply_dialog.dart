import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../utils/typography/airmenu_typography.dart';
import '../../data/models/feedback_model.dart';

class ReplyDialog extends StatefulWidget {
  final FeedbackModel feedback;
  final Function(String) onSubmit;

  const ReplyDialog({
    super.key,
    required this.feedback,
    required this.onSubmit,
  });

  @override
  State<ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends State<ReplyDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_controller.text.trim());
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child:
          Container(
                width: 480,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reply to Customer',
                                style: AirMenuTextStyle.headingH4
                                    .bold700()
                                    .withColor(Colors.grey.shade900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Share your response publicly',
                                style: AirMenuTextStyle.small.withColor(
                                  Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          _CloseButton(
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Customer Review Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _Avatar(initials: widget.feedback.initials),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            widget.feedback.customerName,
                                            style: AirMenuTextStyle.normal
                                                .bold600()
                                                .withColor(
                                                  Colors.grey.shade900,
                                                ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              widget.feedback.orderIdDisplay,
                                              style: AirMenuTextStyle.tiny
                                                  .medium500()
                                                  .withColor(
                                                    Colors.grey.shade600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < widget.feedback.rating
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            size: 16,
                                            color:
                                                index < widget.feedback.rating
                                                ? const Color(0xFFF59E0B)
                                                : Colors.grey.shade300,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '"${widget.feedback.comment}"',
                              style: AirMenuTextStyle.normal
                                  .regularItalic()
                                  .withColor(Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reply Input
                      Text(
                        'Your Reply',
                        style: AirMenuTextStyle.small.bold700().withColor(
                          Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _controller,
                        maxLines: 5,
                        style: AirMenuTextStyle.normal,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a reply';
                          }
                          if (value.trim().length < 10) {
                            return 'Reply must be at least 10 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Thank the customer for their feedback...',
                          hintStyle: AirMenuTextStyle.normal.withColor(
                            Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFDC2626),
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: AirMenuTextStyle.normal
                                  .medium500()
                                  .withColor(Colors.grey.shade600),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12, // Reduced vertical padding
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  24,
                                ), // More rounded (pill shape)
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.send_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Post Reply',
                                  style: AirMenuTextStyle.normal.bold600(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .scale(
                duration: 400.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.9, 0.9),
              )
              .fadeIn(duration: 300.ms),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.grey.shade100 : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: _isHovered ? Colors.grey.shade800 : Colors.grey.shade400,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;

  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFDC2626), const Color(0xFFEF4444)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: AirMenuTextStyle.normal.bold700().withColor(Colors.white),
        ),
      ),
    );
  }
}
