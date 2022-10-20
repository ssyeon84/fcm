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
        private Notification notification; // 모든 mobile os를 아우를수 있는 Notification
        private String token; // 특정 device에 알림을 보내기위해 사용
        private String topic; // 특정 topic에 알림을 보내기 위해 사용
        private Map<String, Object> data;
    }

    @Builder
    @AllArgsConstructor
    @Getter
    public static class Notification {
        private String title;
        private String body;
        private String image;
    }
}
