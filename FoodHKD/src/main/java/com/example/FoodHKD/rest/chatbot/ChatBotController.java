package com.example.FoodHKD.rest.chatbot;

import com.example.FoodHKD.dto.ChatBotRequestDTO;
import com.example.FoodHKD.dto.ChatMessageDTO;
import com.example.FoodHKD.dto.ChatSessionDTO;
import com.example.FoodHKD.model.ChatSession;
import com.example.FoodHKD.service.ChatBotService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.extern.slf4j.Slf4j;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/chatbot")
@Slf4j
@CrossOrigin(origins = "*", maxAge = 3600)
public class ChatBotController {

    @Autowired
    private ChatBotService chatBotService;

    /**
     * Tạo một session chat mới
     */
    @PostMapping("/session/create")
    public ResponseEntity<?> createChatSession(@RequestParam Integer userId, 
                                              @RequestParam(required = false) String sessionName) {
        try {
            ChatSession session = chatBotService.createChatSession(userId, sessionName);
            ChatSessionDTO dto = convertToSessionDTO(session);
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            log.error("Error creating chat session", e);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Gửi tin nhắn và nhận response từ bot
     */
    @PostMapping("/message")
    public ResponseEntity<?> sendMessage(@RequestBody ChatBotRequestDTO request) {
        try {
            if (request.getSessionId() == null || request.getMessage() == null || request.getMessage().trim().isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(Map.of("error", "Session ID and message are required"));
            }

            ChatMessageDTO response = chatBotService.processUserMessage(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error processing message", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to process message: " + e.getMessage()));
        }
    }

    /**
     * Lấy lịch sử chat của một session
     */
    @GetMapping("/session/{sessionId}/history")
    public ResponseEntity<?> getChatHistory(@PathVariable Long sessionId) {
        try {
            List<ChatMessageDTO> history = chatBotService.getChatHistory(sessionId);
            return ResponseEntity.ok(history);
        } catch (Exception e) {
            log.error("Error getting chat history", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to get chat history: " + e.getMessage()));
        }
    }

    /**
     * Lấy danh sách các session chat của user
     */
    @GetMapping("/user/{userId}/sessions")
    public ResponseEntity<?> getUserChatSessions(@PathVariable Integer userId) {
        try {
            List<ChatSession> sessions = chatBotService.getUserChatSessions(userId);
            List<ChatSessionDTO> dtos = sessions.stream()
                    .map(this::convertToSessionDTO)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(dtos);
        } catch (Exception e) {
            log.error("Error getting user chat sessions", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to get sessions: " + e.getMessage()));
        }
    }

    /**
     * Đóng một session chat
     */
    @PostMapping("/session/{sessionId}/close")
    public ResponseEntity<?> closeChatSession(@PathVariable Long sessionId) {
        try {
            ChatSession session = chatBotService.closeChatSession(sessionId);
            ChatSessionDTO dto = convertToSessionDTO(session);
            return ResponseEntity.ok(dto);
        } catch (Exception e) {
            log.error("Error closing chat session", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to close session: " + e.getMessage()));
        }
    }

    /**
     * Lấy danh sách gợi ý thực phẩm dựa trên yêu cầu của user
     */
    @PostMapping("/recommendations")
    public ResponseEntity<?> getRecommendations(@RequestBody ChatBotRequestDTO request) {
        try {
            var recommendations = chatBotService.getRecommendedFoods(
                    request.getMessage(), 
                    request.getPreferences()
            );
            
            Map<String, Object> response = new HashMap<>();
            response.put("recommendations", recommendations);
            response.put("count", recommendations.size());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Error getting recommendations", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Failed to get recommendations: " + e.getMessage()));
        }
    }

    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        return ResponseEntity.ok(Map.of("status", "ChatBot Service is running"));
    }

    /**
     * Chuyển đổi ChatSession thành DTO
     */
    private ChatSessionDTO convertToSessionDTO(ChatSession session) {
        ChatSessionDTO dto = new ChatSessionDTO();
        dto.setId(session.getId());
        dto.setUserId((long) session.getUser().getUserID());
        dto.setSessionName(session.getSessionName());
        dto.setCreatedAt(session.getCreatedAt());
        dto.setUpdatedAt(session.getUpdatedAt());
        dto.setIsActive(session.getIsActive());
        dto.setMessageCount(session.getMessages().size());
        return dto;
    }
}
