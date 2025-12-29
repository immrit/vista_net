import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../../features/support_chat/data/models/ticket_message.dart';

class MessageBubble extends StatelessWidget {
  final TicketMessage message;
  final bool isMe;
  final bool isFirstInSequence;
  final bool isLastInSequence;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.isFirstInSequence = true,
    this.isLastInSequence = true,
  });

  @override
  Widget build(BuildContext context) {
    // Telegram-like colors
    final backgroundColor = isMe ? const Color(0xFFEEFFDE) : Colors.white;
    const textColor = Colors.black;
    // final timeColor = isMe ? const Color(0xFF53B36F) : const Color(0xFFA1AAB3); // Unused

    // Date formatting
    final timeString = intl.DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          top: isFirstInSequence ? 4 : 1,
          bottom: isLastInSequence ? 4 : 1,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(
              isMe ? 16 : (isLastInSequence ? 0 : 16),
            ),
            bottomRight: Radius.circular(
              isMe ? (isLastInSequence ? 0 : 16) : 16,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image/File content
              if (message.type == 'image' && message.mediaUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      message.mediaUrl!,
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Text Content + Time Row
              // We use a specific layout to wrap time appropriately
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 2),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 15,
                        color: textColor,
                      ),
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                  // Time and Status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe
                              ? const Color(0xFF5BA772)
                              : const Color(0xFFA1AAB3),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        // Using a simple icon for read receipt for now
                        // In real TG this checks status (sending, sent, read)
                        Icon(
                          Icons.done_all, // Double tick
                          size: 16,
                          color: Color(0xFF5BA772),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
