import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<Map<String, dynamic>> messages = [];
  final _formKey = GlobalKey<FormState>();
  final _msgController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _submit() async {
    _msgController.text = '';
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  // Fetch messages for the given conversation
  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final response = await Supabase.instance.client
        .from('messages')
        .select()
        .eq('conversation_id', widget.conversationId)
        .order('created_at', ascending: true);

    setState(() {
      messages = (response as List<dynamic>? ?? [])
          .map((e) => {
                'conversation_id': e['conversation_id'] ?? 'Unknown',
                'sender_id': e['sender_id'] ?? 'Unknown',
                'text': e['text'] ?? '',
                'created_at': e['created_at'] ?? '',
              })
          .toList();
    });
    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Detail')),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _msgController,
                decoration: InputDecoration(
                  labelText: 'Message',
                  suffixIcon: IconButton(
                    onPressed: () => _submit(),
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
