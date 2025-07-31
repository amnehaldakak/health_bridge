import 'package:flutter/material.dart';
import 'package:health_bridge/config/content/custom_text_field.dart';
import 'package:health_bridge/config/content/valid.dart';

class ChatBotPatient extends StatefulWidget {
  const ChatBotPatient({super.key});

  @override
  State<ChatBotPatient> createState() => _ChatBotPatientState();
}

class _ChatBotPatientState extends State<ChatBotPatient> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: "Hello! How can I help you today?", isSent: false),
    _ChatMessage(text: "I need some advice on my health.", isSent: true),
    _ChatMessage(text: "Sure! Please tell me more.", isSent: false),
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (_formKey.currentState?.validate() ?? false) {
      if (text.isNotEmpty) {
        setState(() {
          _messages.add(_ChatMessage(text: text, isSent: true));
          _controller.clear();
        });
        // Optionally, trigger bot response here
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isSent = message.isSent;
                  return Align(
                    alignment:
                        isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isSent
                            ? const Color(0xFF018ABE)
                            : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isSent
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                          bottomRight: isSent
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
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
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
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
                          hint1: 'Type your message...'),
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
