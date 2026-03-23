package com.example.FoodHKD.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "chat_messages")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", referencedColumnName = "UserID")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chat_session_id")
    private ChatSession chatSession;

    @Column(columnDefinition = "TEXT")
    private String messageContent;

    @Column(name = "is_bot_response")
    private Boolean isBotResponse;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "message_type")
    private String messageType; // user, bot, recommendation

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (isBotResponse == null) {
            isBotResponse = false;
        }
    }
}
