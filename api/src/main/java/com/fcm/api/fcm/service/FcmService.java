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
        if(target.equals("token")) {
            message = makeTokenMessage(req.getTarget(), req.getTitle(), req.getBody(), req.getImage(), req.getData());
        } else {
            message = makeTopicMessage(req.getTarget(), req.getTitle(), req.getBody(), req.getImage(), req.getData());
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

    // 파라미터를 FCM이 요구하는 body 형태로 만들어준다.
    private String makeTokenMessage(String targetToken, String title, String body, String image, Map<String, Object> data) throws JsonProcessingException {
        FcmMessage fcmMessage = FcmMessage.builder()
                .message(FcmMessage.Message.builder()
                    .token(targetToken)
                    .notification(FcmMessage.Notification.builder()
                        .title(title)
                        .body(body)
                        .image(image)
                        .build()
                    )
                    .android(FcmMessage.Android.builder()
                        .notification(FcmMessage.AndroidNotification.builder()
                            .channel_id("fcm-channel-id") // TODO flutter andriod에 설정한 channel id와 동일해야한다
                            .click_action("FLUTTER_NOTIFICATION_CLICK")
                            .body(body)
                            .build()
                        )
                        .build()
                    )
                    .data(data)
                    .build()
                )
                .validate_only(false)
                .build();
        return objectMapper.writeValueAsString(fcmMessage);
    }

    // 파라미터를 FCM이 요구하는 body 형태로 만들어준다.
    private String makeTopicMessage(String targetToken, String title, String body, String image, Map<String, Object> data) throws JsonProcessingException {
        data.put("click_action", "FLUTTER_NOTIFICATION_CLICK"); // 고정
        FcmMessage fcmMessage = FcmMessage.builder()
                .message(FcmMessage.Message.builder()
                    .topic(targetToken)
                    .notification(FcmMessage.Notification.builder()
                        .title(title)
                        .body(body)
                        .image(image)
                        .build()
                    )
                    .android(FcmMessage.Android.builder()
                        .notification(FcmMessage.AndroidNotification.builder()
                                .channel_id("app-channel-id") // TODO flutter andriod에 설정한 channel id와 동일해야한다
                                .click_action("FLUTTER_NOTIFICATION_CLICK")
                                .body(body)
                                .build()
                        )
                        .build()
                    )
                    .data(data)
                    .build()
                )
                .validate_only(false)
                .build();
        System.out.println(fcmMessage);
        return objectMapper.writeValueAsString(fcmMessage);
    }

    private String getAccessToken() throws IOException {
        // TODO Firebase admin json 파일
        String firebaseConfigPath = "fcm/webview-fcm.json";
        GoogleCredentials googleCredentials = GoogleCredentials
                .fromStream(new ClassPathResource(firebaseConfigPath).getInputStream())
                .createScoped(List.of("https://www.googleapis.com/auth/cloud-platform"));
        googleCredentials.refreshIfExpired();
        return googleCredentials.getAccessToken().getTokenValue();
    }
}
