package com.fcm.api.fcm.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fcm.api.fcm.dto.FcmMessage;
import com.fcm.api.fcm.dto.FcmSendReq;
import com.google.auth.oauth2.GoogleCredentials;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.apache.http.HttpHeaders;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class FcmService {

    // TODO Firebase Project ID
    private String API_URL = "https://fcm.googleapis.com/v1/projects/fcm-app-5149c/messages:send";
    private final ObjectMapper objectMapper;

    public void sendMessage(String target, FcmSendReq req) throws IOException {

        String message;

        Map<String, Object> data = req.getData();
        data.put("title", req.getTitle());
        data.put("body", req.getBody());

        if (target.equals("token")) {
            message = makeTokenMessage(req.getTarget(), data);
        } else {
            message = makeTopicMessage(req.getTarget(), data);
        }

        OkHttpClient client = new OkHttpClient();
        RequestBody requestBody = RequestBody.create(message, MediaType.get("application/json; charset=utf-8"));
        Request request = new Request.Builder()
                .url(API_URL)
                .post(requestBody)
                .addHeader(HttpHeaders.AUTHORIZATION, "Bearer " + getAccessToken())
                .addHeader(HttpHeaders.CONTENT_TYPE, "application/json; UTF-8")
                .build();

        Response response = client.newCall(request).execute();

        log.info(response.body().string());
    }

    // 토큰 전송
    private String makeTokenMessage(String targetToken,
                                    Map<String, Object> data) throws JsonProcessingException {
        FcmMessage fcmMessage = FcmMessage.builder()
                .message(FcmMessage.Message.builder()
                        .token(targetToken)
                        .data(data)
                        .build())
                .validate_only(false)
                .build();
        return objectMapper.writeValueAsString(fcmMessage);
    }

    // 토픽 전송
    private String makeTopicMessage(String targetToken,
                                    Map<String, Object> data) throws JsonProcessingException {
        FcmMessage fcmMessage = FcmMessage.builder()
                .message(FcmMessage.Message.builder()
                        .topic(targetToken)
                        .data(data)
                        .build())
                .validate_only(false)
                .build();
        return objectMapper.writeValueAsString(fcmMessage);
    }

    private String getAccessToken() throws IOException {
        // Firebase admin json 파일
        String firebaseConfigPath = "fcm/webview-fcm.json";
        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new ClassPathResource(firebaseConfigPath).getInputStream())
                .createScoped(List.of("https://www.googleapis.com/auth/cloud-platform"));
        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }
}
