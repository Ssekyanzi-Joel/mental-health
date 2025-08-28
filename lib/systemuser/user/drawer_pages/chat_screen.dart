import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:mind_aware_application/model/message_model.dart';
import 'package:mind_aware_application/services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _showEmoji = false;
  bool _isTyping = false;
  String? _replyText;

  CollectionReference get _chatRef => FirebaseFirestore.instance
      .collection('chats')
      .doc(_auth.currentUser!.uid)
      .collection('messages');

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    ChatMessage userMessage = ChatMessage(
      message: _controller.text,
      isUser: true,
      time: DateTime.now(),
      replyTo: _replyText,
    );

    setState(() {
      _isLoading = true;
      _replyText = null;
    });

    _controller.clear();
    await _chatRef.add(userMessage.toMap());
    _scrollToBottom();

    setState(() => _isTyping = true);
    String aiResponse = await AIService.getResponse(userMessage.message);
    ChatMessage botMessage = ChatMessage(
      message: aiResponse,
      isUser: false,
      time: DateTime.now(),
    );

    await _chatRef.add(botMessage.toMap());
    setState(() {
      _isTyping = false;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onEmojiSelected(Emoji emoji) {
    _controller.text += emoji.emoji;
  }

  void _deleteMessage(String docId) async {
    await _chatRef.doc(docId).delete();
  }

  Widget _buildMessage(ChatMessage msg, String docId) {
    return GestureDetector(
      onLongPress: () {
        if (msg.isUser) _deleteMessage(docId);
      },
      child: ChatBubble(
        clipper: ChatBubbleClipper5(
          type: msg.isUser ? BubbleType.sendBubble : BubbleType.receiverBubble,
        ),
        alignment: msg.isUser ? Alignment.topRight : Alignment.topLeft,
        margin: const EdgeInsets.symmetric(vertical: 5),
        backGroundColor: msg.isUser
            ? Colors.green.shade400
            : Colors.grey.shade200,
        child: Column(
          crossAxisAlignment: msg.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (msg.replyTo != null)
              Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Replying: ${msg.replyTo!}",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            Text(
              msg.message,
              style: TextStyle(color: msg.isUser ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 3),
            Text(
              DateFormat('hh:mm a').format(msg.time),
              style: const TextStyle(fontSize: 10, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/chat_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatRef.orderBy('timestamp').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: SpinKitThreeBounce(color: Colors.green, size: 20),
                    );
                  }

                  List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      ChatMessage msg = ChatMessage.fromMap(
                        docs[index].data() as Map<String, dynamic>,
                      );
                      return _buildMessage(msg, docs[index].id);
                    },
                  );
                },
              ),
            ),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  "AI is typing...",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            if (_isLoading)
              const SpinKitThreeBounce(color: Colors.green, size: 20),
            if (_replyText != null)
              Container(
                padding: const EdgeInsets.all(5),
                color: Colors.black12,
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 20),
                    const SizedBox(width: 5),
                    Expanded(child: Text("Replying to: $_replyText")),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _replyText = null),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () => setState(() => _showEmoji = !_showEmoji),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
            if (_showEmoji)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) => _onEmojiSelected(emoji),
                  config: const Config(
                    //  columns: 7,
                    // verticalSpacing: 0,
                    //  horizontalSpacing: 0,
                    // gridPadding: EdgeInsets.zero,
                    //initCategory: Category.SMILEYS,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
