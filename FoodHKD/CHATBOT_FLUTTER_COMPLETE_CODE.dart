# ChatCopilot Prompt - Flutter Frontend Implementation

## Prompt để Copy-Paste vào ChatCopilot

```
Tôi đang xây dựng ứng dụng Food Ordering với Flutter. Backend Java Spring Boot của tôi đã có sẵn API Chatbot để gợi ý món ăn.

## Backend API Information:

**Base URL**: http://localhost:8080/api/chatbot

**Endpoints**:
1. POST /session/create - Tạo session chat
   - Params: userId (Integer), sessionName (String, optional)
   - Returns: {id, userId, sessionName, createdAt, updatedAt, isActive, messageCount}

2. POST /message - Gửi tin nhắn
   - Body: {message, userId, sessionId, preferences}
   - Returns: {id, messageContent, isBotResponse, createdAt, messageType}

3. GET /session/{sessionId}/history - Lấy lịch sử chat
   - Returns: List of {id, messageContent, isBotResponse, createdAt, messageType}

4. GET /user/{userId}/sessions - Lấy danh sách session của user
   - Returns: List of {id, userId, sessionName, createdAt, updatedAt, isActive, messageCount}

5. POST /session/{sessionId}/close - Đóng session
   - Returns: {id, userId, sessionName, isActive}

6. POST /recommendations - Lấy gợi ý
   - Body: {message, preferences}
   - Returns: {recommendations: List of {foodId, foodName, price, category, reason, matchScore}, count}

7. WebSocket: ws://localhost:8080/api/ws/chatbot
   - Send: {message, userId, sessionId, preferences}
   - Receive: {id, messageContent, isBotResponse, createdAt, messageType}

## Requirements:

1. **Main ChatBot Widget**:
   - FloatingActionButton to open chatbot
   - Chat UI with message bubbles (user messages on right, bot on left)
   - Real-time message display
   - Message input field with send button
   - Scroll to bottom when new messages arrive

2. **Features**:
   - Session management (create, list, close sessions)
   - Chat history persistence
   - Food recommendations with match score
   - User preferences support
   - Error handling and connection status
   - Loading states

3. **UI/UX**:
   - Beautiful chat bubbles with colors
   - Avatar or icon for bot
   - Timestamp for each message
   - Smooth animations
   - Responsive design

4. **Integration**:
   - Use http package for REST API
   - Use web_socket_channel for WebSocket
   - Share userId from user login context
   - Store sessionId in provider or state management

Generate complete, production-ready Flutter code with:
- Proper error handling
- Loading states
- Form validation
- Code comments
- Example usage

Please provide:
1. Main ChatBotWidget class
2. ChatMessage model
3. ChatBotService (API integration)
4. Main UI screens and widgets
5. pubspec.yaml dependencies
6. How to integrate into existing app
```

## Cara Menggunakan Prompt Ini:

1. **Copy seluruh prompt di atas** (dari backtick pembuka sampai penutup)

2. **Buka ChatCopilot** di VS Code

3. **Paste prompt** ke chat window

4. **Tekan Enter** dan tunggu ChatCopilot generate code

5. **Review dan copy** generated code ke project Flutter Anda

## Expected Output dari ChatCopilot:

ChatCopilot akan menghasilkan:
- `chatbot_service.dart` - API integration service
- `models/chat_message.dart` - Data models
- `models/chat_session.dart` - Session model
- `screens/chatbot_screen.dart` - Main chatbot UI
- `widgets/chat_bubble.dart` - Message bubble widget
- `pubspec.yaml` - Dependencies list
- Integration guide

## Alternative: Detailed Step-by-Step Prompt

Jika ingin lebih detail, gunakan prompt ini:

```
# Step 1: Create ChatBot Data Models

Generate Dart models untuk:
1. ChatMessage dengan fields: id, content, isBot, timestamp
2. ChatSession dengan fields: id, userId, sessionName, createdAt, updatedAt, isActive
3. FoodRecommendation dengan fields: foodId, foodName, price, category, reason, matchScore

Gunakan @JsonSerializable untuk JSON serialization.

# Step 2: Create ChatBot Service

Create ChatBotService class dengan methods:
1. createSession(userId, sessionName)
2. sendMessage(sessionId, userId, message, preferences)
3. getChatHistory(sessionId)
4. getUserSessions(userId)
5. closeSession(sessionId)
6. getRecommendations(message, preferences)

Gunakan http package untuk API calls.
Base URL: http://localhost:8080/api/chatbot

# Step 3: Create ChatBot UI

Create ChatBotScreen StatefulWidget dengan:
1. Message list view
2. Message input field
3. Send button
4. Session selector
5. Chat history loading

Include proper error handling dan loading states.

# Step 4: Create Message Bubble Widget

Create ChatBubble widget untuk menampilkan:
1. Message content
2. Avatar/icon (berbeda untuk bot dan user)
3. Timestamp
4. Different styling untuk bot vs user messages
```

## Tips untuk Hasil Terbaik:

1. **Berikan Context Lengkap**: Jelaskan struktur project Anda
2. **Spesifik tentang UI**: Deskripsikan design yang Anda inginkan
3. **Mention Package**: Sebutkan package yang sudah Anda gunakan
4. **State Management**: Sebutkan apakah pakai Provider, GetX, Riverpod, etc
5. **Revisi Iteratif**: Jika output tidak sesuai, berikan feedback detail

## Struktur Folder yang Diharapkan:

```
flutter_app/
├── lib/
│   ├── services/
│   │   └── chatbot_service.dart
│   ├── models/
│   │   ├── chat_message.dart
│   │   ├── chat_session.dart
│   │   └── food_recommendation.dart
│   ├── screens/
│   │   └── chatbot_screen.dart
│   ├── widgets/
│   │   ├── chat_bubble.dart
│   │   ├── message_input.dart
│   │   └── session_selector.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

## Dependencies yang Dibutuhkan:

Tambahkan ke `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  web_socket_channel: ^2.4.0
  json_annotation: ^4.8.0
  provider: ^6.0.0  # optional, untuk state management

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

## Quick Start untuk Integrasi:

1. Buat folder `lib/services`, `lib/models`, `lib/widgets`, `lib/screens`
2. Generate code dari ChatCopilot untuk setiap file
3. Update `pubspec.yaml` dengan dependencies
4. Run `flutter pub get`
5. Integrate ChatBotScreen ke navigation menu
6. Pass userId dari login context
7. Test dengan running app

## Common Issues & Solutions:

1. **WebSocket connection failed**:
   - Pastikan backend running di http://localhost:8080
   - Check firewall settings
   - Verify CORS configuration

2. **API not found**:
   - Verify base URL correct
   - Check endpoint paths
   - Ensure backend server running

3. **JSON parsing errors**:
   - Run `flutter pub run build_runner build`
   - Check JSON model generated correctly
   - Verify API response format matches model

4. **State management issues**:
   - Jika pakai Provider, pastikan setup correct
   - Dispose controllers properly
   - Check context availability

## Next Steps:

1. Generate code dengan ChatCopilot menggunakan prompt di atas
2. Review dan test generated code
3. Customize UI sesuai app design
4. Add analytics/logging jika perlu
5. Optimize performance untuk large chat histories
```

Sekarang bạn sẽ:

1. **Sao chép toàn bộ prompt ở trên**
2. **Mở ChatCopilot trong VS Code**
3. **Paste prompt vào chat**
4. **Tunggu code được generate**
5. **Copy code vào Flutter project**

Code yang ChatCopilot generate sẽ tự động đồng bộ với Backend API mà tôi đã tạo! 🚀
<function_calls>
<invoke name="create_file">
<parameter name="content">import 'package:flutter/material.dart';
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
