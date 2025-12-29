import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

class AnimatedChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File, String) onSendFile;
  final bool isRecording;
  final Function() onStartRecording;
  final Function() onStopRecording;
  final Function() onCancelRecording;

  const AnimatedChatInput({
    super.key,
    required this.onSendMessage,
    required this.onSendFile,
    this.isRecording = false,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onCancelRecording,
  });

  @override
  State<AnimatedChatInput> createState() => _AnimatedChatInputState();
}

class _AnimatedChatInputState extends State<AnimatedChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (_showSendButton != hasText) {
      setState(() {
        _showSendButton = hasText;
      });
    }
  }

  void _handleSend() {
    if (_textController.text.trim().isEmpty) return;
    widget.onSendMessage(_textController.text.trim());
    _textController.clear();
  }

  Future<void> _handleAttach() async {
    // Show bottom sheet or use FilePicker directly
    // Ideally use a modal bottom sheet with options: Gallery, File, Location, etc.
    _showAttachmentSheet();
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _AttachmentOption(
                  icon: Icons.image_rounded,
                  color: Colors.purple,
                  label: 'گالری',
                  onTap: () => _pickFile(FileType.image, 'image'),
                ),
                _AttachmentOption(
                  icon: Icons.insert_drive_file_rounded,
                  color: Colors.blue,
                  label: 'فایل',
                  onTap: () => _pickFile(FileType.any, 'file'),
                ),
                _AttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  color: Colors.red,
                  label: 'دوربین',
                  onTap: () {}, // TODO: Implement Camera
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(FileType type, String messageType) async {
    Navigator.pop(context); // Close sheet
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: type);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      widget.onSendFile(file, messageType);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRecording) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            const Icon(Icons.mic, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text(
              'در حال ضبط... 0:00',
              style: TextStyle(color: Colors.red),
            ), // Timer
            const Spacer(),
            TextButton(
              onPressed: widget.onCancelRecording,
              child: const Text('لغو', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white),
                onPressed: widget.onStopRecording, // Send voice
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attach Button
            IconButton(
              icon: const Icon(
                Icons.attach_file_rounded,
                color: Colors.grey,
                size: 28,
              ),
              onPressed: _handleAttach,
            ),

            // Text Input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'پیام...',
                    hintTextDirection: TextDirection.rtl,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send / Mic Button
            GestureDetector(
              onLongPress: _textController.text.isEmpty
                  ? widget.onStartRecording
                  : null,
              onTap: _showSendButton
                  ? _handleSend
                  : null, // If empty, tapping mic could act as hint or nothing
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _showSendButton
                      ? const Color(0xFF0088CC)
                      : Colors.grey[200], // TG Blue
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _showSendButton
                      ? Icons.arrow_upward_rounded
                      : Icons.mic_rounded,
                  color: _showSendButton ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
