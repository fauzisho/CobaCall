//
//  MClient.m
//  Madura
//
//  Created by ashari juang on 30/12/16.
//  Copyright © 2016 mhealth. All rights reserved.
//

#import "AgoraClient.h"
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "QiscusCallSDKWrapper.h"

#define VENDOR_KEY @""

@interface AgoraClient()<AgoraRtcEngineDelegate>
@property (nonatomic, strong) AgoraRtcEngineKit *agoraKit;

@end

@implementation AgoraClient

- (instancetype)initWithDelegate:(id<AgoraCallDelegate>)delegate appKey:(NSString *)appKey room:(NSString *)room video:(Boolean)video{
    if (self = [super init]) {
        _delegate = delegate;
        [self initializeAgoraEngine:(appKey)];
        [self setupVideo:(video)];
        [self joinChannel:(room)];
    }
    return self;
}

- (void)initializeAgoraEngine:(NSString *)key {
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:key delegate:self];
    [self.agoraKit setDefaultAudioRouteToSpeakerphone:NO];
    NSString *version = [AgoraRtcEngineKit getSdkVersion];
    NSLog(@"%@", version);
}

- (void)setupLocalVideo:(UIView *)localVideo {
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 0;
    // UID = 0 means we let Agora pick a UID for us
    
    videoCanvas.view = localVideo;
    videoCanvas.renderMode = AgoraRtc_Render_Hidden;
    [self.agoraKit setupLocalVideo:videoCanvas];

}
    
- (void)setupVideo:(Boolean)video {
    if (video) {
        // Switches from audio to video mode
        [self.agoraKit setDefaultAudioRouteToSpeakerphone:YES];
        [self.agoraKit enableVideo];
        [self.agoraKit setVideoProfile:AgoraRtc_VideoProfile_360P swapWidthAndHeight: false];
        // Default video profile is 360P
    }else {
        // Switch from video to audio mode.
        [self.agoraKit setDefaultAudioRouteToSpeakerphone:NO];
        [self.agoraKit disableVideo];
    }
}
    
- (void)setupRemoteVideo:(UIView *)viewVideo {
    self.remoteVideo = viewVideo;
}
    
- (void)joinChannel:(NSString *)room {
    [self.agoraKit joinChannelByKey:nil channelName:room info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }];
}

- (void)leaveChannel {
    [self.agoraKit leaveChannel:^(AgoraRtcStats *stat) {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [self.remoteVideo removeFromSuperview];
        [self.localVideo removeFromSuperview];
        self.agoraKit = nil;
    }];
}

- (void)setVideo:(Boolean)enable {
    [self.agoraKit muteLocalVideoStream:enable];
}
    
- (void)setSpeaker:(Boolean)enable {
    [self.agoraKit setEnableSpeakerphone:enable];
}
    
- (void)toggleCamera {
    [self.agoraKit switchCamera];
}
    
- (void)setMicrophone:(Boolean)enable {
    [self.agoraKit muteLocalAudioStream:enable];
}
    
//- (Boolean)isVideoEnable {
//    return [self.agoraKit isSpeakerphoneEnabled];
//}

// MARK: Agora Delegate
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
    NSLog(@"%@", engine);
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = uid;
    // Since we are making a simple 1:1 video chat app, for simplicity sake, we are not storing the UIDs. You could use a mechanism such as an array to store the UIDs in a channel.

    videoCanvas.view = _remoteVideo;
    videoCanvas.renderMode = AgoraRtc_Render_Fit;
    [self.agoraKit setupRemoteVideo:videoCanvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    [_delegate didJoinedOfUid:uid elapsed:elapsed];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didRejoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    [_delegate didRejoinChannel: channel withUid:uid elapsed:elapsed];
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine {
    [_delegate connectionDidLost];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraRtcUserOfflineReason)reason {
    int offlineReason = 0;
    if(reason == AgoraRtc_UserOffline_Quit){
        offlineReason = 0;
    }else if (reason == AgoraRtc_UserOffline_Dropped) {
        offlineReason = 1;
    }else {
        offlineReason = 2;
    }
    [_delegate didOfflineOfUid:offlineReason];
    
}
    
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid {
    [_delegate didVideoMuted:muted];
}
    
-(void)rtcEngine:(AgoraRtcEngineKit *)engine networkQuality:(NSUInteger)uid txQuality:(AgoraRtcQuality)txQuality rxQuality:(AgoraRtcQuality)rxQuality {
    NSString *tx = @"";
    NSString *rx = @"";
    
    switch (txQuality) {
        case 0:
            tx = @"unknown";
            break;
        case 1:
            tx = @"Excellent";
            break;
        case 2:
            tx = @"Good";
            break;
        case 3:
            tx = @"Poor";
            break;
        case 4:
            tx = @"Bad";
            break;
        case 5:
            tx = @"VBad";
            break;
        case 6:
            tx = @"Down";
            break;
        default:
        break;
    }
    
    // MARK: Refactor this case
    switch (rxQuality) {
        case 0:
            rx = @"unknown";
            break;
        case 1:
            rx = @"Excellent";
            break;
        case 2:
            rx = @"Good";
            break;
        case 3:
            rx = @"Poor";
            break;
        case 4:
            rx = @"Bad";
            break;
        case 5:
            rx = @"VBad";
            break;
        case 6:
            rx = @"Down";
            break;
        default:
        break;
    }
    
    [_delegate txQuality:tx rxQuality:rx];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine reportRtcStats:(AgoraRtcStats*)stats {
    NSDictionary *data =
    @{
        @"rxBytes"          : [NSString stringWithFormat:@"%@",  @(stats.rxBytes)],
        @"txBytes"          : [NSString stringWithFormat:@"%@",  @(stats.txBytes)],
        @"duration"         : [NSString stringWithFormat:@"%@",  @(stats.duration)],
        @"txAudioKBitrate"  : [NSString stringWithFormat:@"%@",  @(stats.txAudioKBitrate)],
        @"txVideoKBitrate"  : [NSString stringWithFormat:@"%@",  @(stats.txVideoKBitrate)],
        @"rxAudioKBitrate"  : [NSString stringWithFormat:@"%@",  @(stats.rxAudioKBitrate)],
        @"rxVideoKBitrate"  : [NSString stringWithFormat:@"%@",  @(stats.rxVideoKBitrate)],
    };
    [_delegate reportCallStats:data];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didLeaveChannelWithStats:(AgoraRtcStats*)stats {
    
    NSDictionary *data =
    @{
        @"rxBytes"          : [NSString stringWithFormat:@"%@",  @(stats.rxBytes)],
        @"txBytes"          : [NSString stringWithFormat:@"%@",  @(stats.txBytes)],
        @"duration"         : [NSString stringWithFormat:@"%@",  @(stats.duration)],
        @"txAudioKBitrate"  : [NSString stringWithFormat:@"%@",  @(stats.txAudioKBitrate)],
        @"txVideoKBitrate"  : [NSString stringWithFormat:@"%@",  @(stats.txVideoKBitrate)],
        @"rxAudioKBitrate"  : [NSString stringWithFormat:@"%@",  @(stats.rxAudioKBitrate)],
        @"rxVideoKBitrate"  : [NSString stringWithFormat:@"%@",  @(stats.rxVideoKBitrate)],
    };
    
    [_delegate didLeaveChannelWithInfo:data];
}
    
@end
