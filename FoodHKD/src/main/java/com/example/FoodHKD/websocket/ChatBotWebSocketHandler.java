package com.example.FoodHKD.websocket;

import com.example.FoodHKD.dto.ChatBotRequestDTO;
import com.example.FoodHKD.dto.ChatMessageDTO;
import com.example.FoodHKD.service.ChatBotService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.*;

@Service
@Slf4j
public class ChatBotWebSocketHandler extends TextWebSocketHandler {

    @Autowired
    private ChatBotService chatBotService;

    private final ObjectMapper objectMapper = new ObjectMapper();
    
    // Lưu trữ các session theo sessionId
    private static final Map<Long, Set<WebSocketSession>> sessionConnections = new HashMap<>();
    // Lưu trữ mapping giữa WebSocketSession và chatSessionId
    private static final Map<WebSocketSession, Long> sessionMapping = new HashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("WebSocket connection established: {}", session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            String payload = message.getPayload();
            log.info("Received message: {}", payload);

            // Parse incoming message
            ChatBotRequestDTO request = objectMapper.readValue(payload, ChatBotRequestDTO.class);

            if (request.getSessionId() == null) {
                sendError(session, "Session ID is required");
                return;
            }

            // Lưu lại mapping
            sessionMapping.put(session, request.getSessionId());
            sessionConnections.computeIfAbsent(request.getSessionId(), k -> new HashSet<>()).add(session);

            // Xử lý tin nhắn
            ChatMessageDTO response = chatBotService.processUserMessage(request);

            // Gửi response tới client
            String responseJson = objectMapper.writeValueAsString(response);
            session.sendMessage(new TextMessage(responseJson));

            // Broadcast tới tất cả các client trong session này (nếu có)
            broadcastToSession(request.getSessionId(), response);

        } catch (Exception e) {
            log.error("Error handling WebSocket message", e);
            sendError(session, "Error processing message: " + e.getMessage());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, org.springframework.web.socket.CloseStatus status) throws Exception {
        Long chatSessionId = sessionMapping.remove(session);
        if (chatSessionId != null) {
            Set<WebSocketSession> sessions = sessionConnections.get(chatSessionId);
            if (sessions != null) {
                sessions.remove(session);
                if (sessions.isEmpty()) {
                    sessionConnections.remove(chatSessionId);
                }
            }
        }
        log.info("WebSocket connection closed: {}", session.getId());
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("WebSocket transport error: {}", exception.getMessage(), exception);
    }

    /**
     * Gửi error message
     */
    private void sendError(WebSocketSession session, String errorMessage) {
        try {
            Map<String, Object> error = new HashMap<>();
            error.put("error", errorMessage);
            error.put("timestamp", System.currentTimeMillis());
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(error)));
        } catch (IOException e) {
            log.error("Failed to send error message", e);
        }
    }

    /**
     * Broadcast message tới tất cả các client trong session
     */
    private void broadcastToSession(Long chatSessionId, ChatMessageDTO message) {
        Set<WebSocketSession> sessions = sessionConnections.get(chatSessionId);
        if (sessions != null) {
            try {
                String messageJson = objectMapper.writeValueAsString(message);
                for (WebSocketSession session : sessions) {
                    if (session.isOpen()) {
                        session.sendMessage(new TextMessage(messageJson));
                    }
                }
            } catch (IOException e) {
                log.error("Error broadcasting message", e);
            }
        }
    }

    /**
     * Gửi message tới một session cụ thể
     */
    public void sendToSession(Long chatSessionId, ChatMessageDTO message) {
        broadcastToSession(chatSessionId, message);
    }
}
