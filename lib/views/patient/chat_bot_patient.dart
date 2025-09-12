import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_bridge/config/content/custom_text_field.dart';
import 'package:health_bridge/config/content/valid.dart';
import 'package:health_bridge/local/app_localizations.dart';
import 'package:health_bridge/providers/auth_provider.dart';
import 'package:health_bridge/service/api_service.dart';

class ChatBotPatient extends ConsumerStatefulWidget {
  const ChatBotPatient({super.key});

  @override
  ConsumerState<ChatBotPatient> createState() => _ChatBotPatientState();
}

class _ChatBotPatientState extends ConsumerState<ChatBotPatient> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<_ChatMessage> _messages = [];

  bool _isLoading = false;
  Map<String, dynamic>? _patientData;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPatientData);
  }

  Future<void> _loadPatientData() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.getPatientData();

      setState(() {
        _patientData = data;
      });
    } catch (e) {
      debugPrint("❌ خطأ في جلب بيانات المريض: $e");
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (_formKey.currentState?.validate() ?? false) {
      if (text.isNotEmpty) {
        setState(() {
          _messages.add(_ChatMessage(text: text, isSent: true));
          _controller.clear();
          _isLoading = true;
        });

        try {
          if (_patientData == null) {
            throw Exception("بيانات المريض غير متوفرة");
          }

          final botReply = await ApiService.sendMessage(text, _patientData!);

          setState(() {
            _messages.add(_ChatMessage(text: botReply, isSent: false));
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _messages.add(_ChatMessage(
              text: AppLocalizations.of(context)!.get('error_sending_message'),
              isSent: false,
            ));
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                reverse: false,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator(loc!);
                  }

                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            const Divider(height: 1),
            _buildInputArea(loc!),
          ],
        ),
      ),
    );
  }

  /// 🔹 ويدجت لعرض رسالة
  Widget _buildMessageBubble(_ChatMessage message) {
    final isSent = message.isSent;
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isSent ? const Color(0xFF018ABE) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isSent ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight:
                isSent ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isSent ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// 🔹 ويدجت لعرض مؤشر "يكتب..."
  Widget _buildTypingIndicator(AppLocalizations loc) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              loc.get('typing'),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 ويدجت لعرض خانة الكتابة وزر الإرسال
  Widget _buildInputArea(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: CustomTextField(
                mycontroller: _controller,
                valid: (p0) {
                  return Valid().vaidInput(p0!, 1, 200);
                },
                max: 1,
                hint1: loc.get('type_message_hint'),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isSent;
  _ChatMessage({required this.text, required this.isSent});
}
