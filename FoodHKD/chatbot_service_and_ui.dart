import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

// Models
class ChatMessage {
  final int id;
  final String messageContent;
  final bool isBotResponse;
  final DateTime createdAt;
  final String messageType;

  ChatMessage({
    required this.id,
    required this.messageContent,
    required this.isBotResponse,
    required this.createdAt,
    required this.messageType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      messageContent: json['messageContent'] ?? '',
      isBotResponse: json['isBotResponse'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      messageType: json['messageType'] ?? 'user',
    );
  }
}

class ChatSession {
  final int id;
  final int userId;
  final String sessionName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int messageCount;

  ChatSession({
    required this.id,
    required this.userId,
    required this.sessionName,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.messageCount,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      sessionName: json['sessionName'] ?? 'Chat Session',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      isActive: json['isActive'] ?? true,
      messageCount: json['messageCount'] ?? 0,
    );
  }
}

// Service
class ChatBotService {
  final String baseUrl;
  late WebSocketChannel _channel;
  Function(ChatMessage)? onMessageReceived;
  Function(String)? onError;

  ChatBotService({this.baseUrl = 'http://localhost:8080'});

  // Create new chat session
  Future<ChatSession> createSession(int userId, {String? sessionName}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chatbot/session/create'),
        queryParameters: {
          'userId': userId.toString(),
          if (sessionName != null) 'sessionName': sessionName,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ChatSession.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create session: ${response.statusCode}');
      }
    } catch (e) {
      onError?.call('Error creating session: $e');
      rethrow;
    }
  }

  // Send message and get response
  Future<ChatMessage> sendMessage(
    int sessionId,
    int userId,
    String message, {
    String? preferences,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chatbot/message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'userId': userId,
          'sessionId': sessionId,
          'preferences': preferences ?? '',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return ChatMessage.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      onError?.call('Error sending message: $e');
      rethrow;
    }
  }

  // Get chat history
  Future<List<ChatMessage>> getChatHistory(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chatbot/session/$sessionId/history'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get history: ${response.statusCode}');
      }
    } catch (e) {
      onError?.call('Error loading history: $e');
      rethrow;
    }
  }

  // Get user sessions
  Future<List<ChatSession>> getUserSessions(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chatbot/user/$userId/sessions'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatSession.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get sessions: ${response.statusCode}');
      }
    } catch (e) {
      onError?.call('Error loading sessions: $e');
      rethrow;
    }
  }

  // Close session
  Future<ChatSession> closeSession(int sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chatbot/session/$sessionId/close'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ChatSession.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to close session: ${response.statusCode}');
      }
    } catch (e) {
      onError?.call('Error closing session: $e');
      rethrow;
    }
  }

  // Connect to WebSocket
  void connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080/api/ws/chatbot'),
      );

      _channel.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data is Map && data.containsKey('error')) {
              onError?.call(data['error']);
            } else {
              onMessageReceived?.call(ChatMessage.fromJson(data));
            }
          } catch (e) {
            onError?.call('Error parsing message: $e');
          }
        },
        onError: (error) {
          onError?.call('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
        },
      );
    } catch (e) {
      onError?.call('Failed to connect WebSocket: $e');
    }
  }

  // Send message via WebSocket
  void sendWebSocketMessage(int sessionId, int userId, String message) {
    try {
      _channel.sink.add(jsonEncode({
        'message': message,
        'userId': userId,
        'sessionId': sessionId,
        'preferences': '',
      }));
    } catch (e) {
      onError?.call('Error sending WebSocket message: $e');
    }
  }

  // Close connection
  void disconnect() {
    _channel.sink.close();
  }
}

// UI Widget
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
  late ChatBotService chatBotService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];
  int? _currentSessionId;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    chatBotService = ChatBotService(baseUrl: widget.baseUrl);
    chatBotService.onMessageReceived = _handleMessageReceived;
    chatBotService.onError = _handleError;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      setState(() => _isConnecting = true);
      final session = await chatBotService.createSession(widget.userId);
      setState(() {
        _currentSessionId = session.id;
        _isConnecting = false;
      });
      await _loadChatHistory();
    } catch (e) {
      setState(() => _isConnecting = false);
      _showError('Failed to initialize chat: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    if (_currentSessionId == null) return;
    try {
      final history = await chatBotService.getChatHistory(_currentSessionId!);
      setState(() {
        messages = history;
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });
      _scrollToBottom();
    } catch (e) {
      _showError('Failed to load history: $e');
    }
  }

  void _handleMessageReceived(ChatMessage message) {
    setState(() {
      messages.add(message);
    });
    _scrollToBottom();
  }

  void _handleError(String error) {
    _showError(error);
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _currentSessionId == null) return;

    final message = _messageController.text;
    _messageController.clear();

    setState(() {
      messages.add(ChatMessage(
        id: messages.length,
        messageContent: message,
        isBotResponse: false,
        createdAt: DateTime.now(),
        messageType: 'user',
      ));
      _isLoading = true;
      _errorMessage = '';
    });

    _scrollToBottom();

    try {
      final response = await chatBotService.sendMessage(
        _currentSessionId!,
        widget.userId,
        message,
      );

      setState(() {
        messages.add(response);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to send message: $e');
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
    chatBotService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food Assistant'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ],
              ),
            ),
          if (_isConnecting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: messages.isEmpty && !_isConnecting
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ask for food recommendations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isBotResponse ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isBotResponse
              ? Colors.grey.shade300
              : Colors.deepPurple.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.messageContent,
              style: TextStyle(
                color: message.isBotResponse ? Colors.black : Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                color: message.isBotResponse
                    ? Colors.black54
                    : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask for food recommendations...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: _messageController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _messageController.clear()),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            mini: true,
            backgroundColor: Colors.deepPurple,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
