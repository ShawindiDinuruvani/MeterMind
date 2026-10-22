import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class AiAssistantSheet extends StatefulWidget {
  const AiAssistantSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiAssistantSheet(),
    );
  }

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'Hello Nimal! I am your MeterMind AI Field Copilot. How can I help you on your Homagama route today?',
    }
  ];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'CEB Meter Error Codes',
    'Tampered Seal Protocol',
    'Domestic Tariff Slabs',
    'Premises Inaccessible',
  ];

  void _sendMessage(String query) async {
    if (query.trim().isEmpty) return;
    final userText = query.trim();
    _controller.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': userText});
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final reply = AIService().getCopilotAnswer(userText);
    if (mounted) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': reply});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkLine : AppColors.line,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Sheet Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.yellowLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('ϟ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MeterMind AI Copilot',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Field Officer Assistant · Homagama District',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.ink
                          : (isDark ? const Color(0xFF354138) : const Color(0xFFEFF2EB)),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(16),
                        bottomLeft: !isUser ? const Radius.circular(2) : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      m['text'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        height: 1.45,
                        color: isUser ? Colors.white : textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.amber),
                  ),
                  const SizedBox(width: 8),
                  Text('MeterMind AI thinking...', style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),

          // Quick prompt chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _quickPrompts.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(p),
                    labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                    backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                    side: BorderSide(color: isDark ? AppColors.darkLine : AppColors.line),
                    onPressed: () => _sendMessage(p),
                  ),
                );
              }).toList(),
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Ask about meter codes, tariffs, or safety...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF354138) : const Color(0xFFF4F6F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.ink,
                  ),
                  icon: const Icon(Icons.send_rounded, size: 20),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
