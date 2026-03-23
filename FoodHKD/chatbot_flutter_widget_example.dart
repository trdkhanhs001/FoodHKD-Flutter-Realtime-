// Flutter ChatBot Widget Example
// File: lib/widgets/chatbot_widget.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ChatMessage {
  final String content;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isBot,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['messageContent'] ?? '',
      isBot: json['isBotResponse'] ?? false,
      timestamp: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}

class ChatBotWidget extends StatefulWidget {
  final int userId;
  final String baseUrl;

  const ChatBotWidget({
    Key? key,
    required this.userId,
    this.baseUrl = 'http://localhost:8080',
  }) : super(key: key);

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> messages = [];
  late WebSocketChannel _channel;
  
  long? _sessionId;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // สร้าง session chat ใหม่
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/api/chatbot/session/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': widget.userId,
          'sessionName': 'Chat Session - ${DateTime.now()}',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _sessionId = data['id'];
        });

        // เชื่อมต่อ WebSocket
        _connectWebSocket();

        // โหลดประวัติแชท
        await _loadChatHistory();
      } else {
        setState(() {
          _error = 'Failed to create chat session: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error initializing chat: $e';
      });
    }
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080/api/ws/chatbot'),
      );

      _channel.stream.listen(
        (message) {
          final data = jsonDecode(message);
          final chatMessage = ChatMessage.fromJson(data);
          setState(() {
            messages.add(chatMessage);
          });
          _scrollToBottom();
        },
        onError: (error) {
          setState(() {
            _error = 'WebSocket error: $error';
          });
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to connect WebSocket: $e';
      });
    }
  }

  Future<void> _loadChatHistory() async {
    if (_sessionId == null) return;

    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/api/chatbot/session/$_sessionId/history'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          messages = data.map((json) => ChatMessage.fromJson(json)).toList();
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading chat history: $e';
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _sessionId == null) {
      return;
    }

    final userMessage = _messageController.text;
    _messageController.clear();

    // เพิ่มข้อความของผู้ใช้ลงในรายการ
    setState(() {
      messages.add(ChatMessage(
        content: userMessage,
        isBot: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _error = '';
    });

    _scrollToBottom();

    try {
      // ส่งข้อความผ่าน REST API
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/api/chatbot/message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': userMessage,
          'userId': widget.userId,
          'sessionId': _sessionId,
          'preferences': '',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botMessage = ChatMessage.fromJson(data);
        
        setState(() {
          messages.add(botMessage);
          _isLoading = false;
        });
        
        _scrollToBottom();
      } else {
        setState(() {
          _error = 'Error sending message: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to send message: $e';
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_channel != null) {
      _channel.sink.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food Assistant'),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (_error.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.red.shade100,
              child: Text(
                _error,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isBot ? Colors.grey.shade300 : Colors.blue.shade500,
          borderRadius: BorderRadius.circular(12.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isBot ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isBot
                    ? Colors.black54
                    : Colors.white70,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
