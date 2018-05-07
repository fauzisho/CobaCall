//
//  CallTrackingEvents.swift
//  QCall
//
//  Created by asharijuang on 5/11/17.
//  Copyright © 2017 qiscus. All rights reserved.
//

import Foundation

class CallTrackingEvents {
    
    public static let CALLER = "caller"
    
    // Join call
    public static let CONSULTATION_VIDEO_PAGELOAD = "consultation_video_pageload"
    public static let CONSULTATION_VOICE_PAGELOAD = "consultation_voice_pageload"
    
    // Parameter
    public static let VIDEO_DIALING_DURATION    = "video_dialing_duration"
    public static let VOICE_DIALING_DURATION    = "voice_dialing_duration"
    
    public static let CONSULTATION_VOICE_DIALING_PAGELOAD   = "consultation_voice_dialing_pageload"
    public static let CONSULTATION_VIDEO_DIALING_PAGELOAD   = "consultation_video_dialing_pageload"
    
    // Muted
    public static let CALL_CONSULTATION_VOICE_MUTE  = "consultation_voice_mute"
    public static let CONSULTATION_VIDEO_MUTE       = "consultation_video_mute"
    public static let CONSULTATION_VIDEO_PAUSEVIDEO = "consultation_video_pausevideo"
    // Parameter
    public static let IS_MUTE   = "is_mute"
    public static let IS_PAUSEVIDEO                 = "is_pausevideo"
    
    
    public static let CONSULTATION_VOICE_SPEAKER_BUTTON = "consultation_voice_speaker_button"
    public static let CONSULTATION_VIDEO_SPEAKER_BUTTON = "consultation_video_speaker_button"
    // Parameter
    public static let IS_SPEAKER_ON                     = "is_speaker_on"
    
    public static let CONSULTATION_VIDEO_CAMERASWITCH   = "consultation_video_cameraswitch"
    
    // Not Enough Balance
    public static let INSUFFICIENT_BALANCE_PAGELOAD     = "insufficient_balance_pageload"
    public static let TRANSACTION_TYPE                  = "transaction_type"
    public static let POPUP_TIME                        = "popup_time"
    
    // Call Droped
    public static let CONSULTATION_VOICE_DROPPED        = "consultation_voice_dropped"
    public static let CONSULTATION_VIDEO_DROPPED        = "consultation_video_dropped"
    
    // Parameter
    public static let VOICE_CONNECTING_DURATION             = "voice_connecting_duration"
    public static let VIDEO_CONNECTING_DURATION             = "video_connecting_duration"
    public static let AGORA_TRANSFER_NETWORK_QUALITY_VALUE  = "agora_transfer_network_quality_value"
    public static let AGORA_RECEIVED_NETWORK_QUALITY_VALUE  = "agora_received_network_quality_value"
    
    // End Call
    public static let CONSULTATION_VOICE_END = "consultation_voice_end"
    public static let CONSULTATION_VIDEO_END = "consultation_video_end"
}
