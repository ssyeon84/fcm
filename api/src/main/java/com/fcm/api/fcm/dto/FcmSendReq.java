package com.fcm.api.fcm.dto;

import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import java.util.Map;

@Data
public class FcmSendReq {

    @ApiModelProperty(value = "target", position = 1)
    private String target;

    @ApiModelProperty(value = "제목", position = 1)
    private String title;

    @ApiModelProperty(value = "내용", position = 1)
    private String body;

    @ApiModelProperty(value = "data", position = 1)
    private Map<String, Object> data;
}
