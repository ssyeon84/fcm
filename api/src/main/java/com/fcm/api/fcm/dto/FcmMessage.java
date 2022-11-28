package com.fcm.api.fcm.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.util.Map;

@Builder
@AllArgsConstructor
@Getter
public class FcmMessage {
    private boolean validate_only;
    private Message message;    
    
    @Builder
    @AllArgsConstructor
    @Getter
    public static class Message {
        private Map<String, Object> data;
        private String token;
        private String topic;
    }
}
