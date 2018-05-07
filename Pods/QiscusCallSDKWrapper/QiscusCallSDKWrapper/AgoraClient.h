//
//  MClient.h
//  Madura
//
//  Created by ashari juang on 30/12/16.
//  Copyright © 2016 mhealth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CallConnectionState)  {
    ConnectionChecking      = 0,
    ConnectionConnecting    = 1,
    ConnectionConnected     = 2,
    ConnectionCompleted     = 3,
    ConnectionFailed        = 4,
    ConnectionDisconnected  = 5,
    ConnectionClosed        = 6,
    ConnectionRejoined      = 7,
    ConnectionDrop          = 8,
    ConnectionLost          = 9,
};

@protocol AgoraCallDelegate <NSObject>

- (void) didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;
- (void) didRejoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;
- (void) txQuality:(NSString *)txQuality rxQuality:(NSString *)rxQuality;

- (void)connectionDidLost;

- (void)didOfflineOfUid:(int)reason;

- (void)didLeaveChannelWithInfo:(NSDictionary *)info;

- (void)didVideoMuted:(BOOL)muted;
    
/**
 *  Statistics of rtc engine status. Updated every two seconds.
 */
- (void)reportCallStats:(NSDictionary *)info;

@end

@interface AgoraClient : NSObject

@property(nonatomic, weak) id<AgoraCallDelegate> delegate;

@property (strong, nonatomic) UIView *localVideo;
@property (strong, nonatomic) UIView *remoteVideo;

- (instancetype)initWithDelegate:(id<AgoraCallDelegate>)delegate appKey:(NSString *)appKey room:(NSString *)room video:(Boolean)video;

- (void)setupLocalVideo:(UIView *)videoView;
- (void)setupRemoteVideo:(UIView *)videoView;
- (void)leaveChannel;
- (void)setVideo:(Boolean)enable;
- (void)setSpeaker:(Boolean)enable;
- (void)toggleCamera;
- (void)setMicrophone:(Boolean)enable;

@end



