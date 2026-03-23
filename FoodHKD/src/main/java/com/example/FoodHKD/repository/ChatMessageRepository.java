package com.example.FoodHKD.repository;

import com.example.FoodHKD.model.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByChatSessionIdOrderByCreatedAtDesc(Long chatSessionId);
    List<ChatMessage> findByUserUserIDOrderByCreatedAtDesc(Integer userId);
}
