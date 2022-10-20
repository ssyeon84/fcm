package com.fcm.api.fcm;

import com.fcm.api.fcm.dto.FcmSendReq;
import com.fcm.api.fcm.service.FcmService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;


@Api(tags = "fcm", protocols = "http")
@Slf4j
@RestController
public class FcmApi {

    @Autowired
    private FcmService fcmService;

    @ApiOperation(value = "토큰에 메세지 전송", notes = "디바이스 토큰에 메세지를 전송합니다.")
    @PostMapping(path = "/fcm/send/token")
    public void sendToken(@RequestBody FcmSendReq req) throws Exception {
        fcmService.sendMessage("token", req);
    }

    @ApiOperation(value = "토픽에 메세지 전송", notes = "전체 메세지를 전송합니다. (현재 all 토픽 지정)")
    @PostMapping(path = "/fcm/send/topic")
    public void sendTopic(@RequestBody FcmSendReq req) throws Exception {
        fcmService.sendMessage("topic", req);
    }

}
