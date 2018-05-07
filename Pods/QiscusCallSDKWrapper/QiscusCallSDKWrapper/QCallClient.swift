//
//  MaduraClient.swift
//  Madura
//
//  Created by ashari juang on 29/12/16.
//  Copyright © 2016 mhealth. All rights reserved.
//

import UIKit
import SwiftyJSON

// Call wraper from agora client
class QCallClient: NSObject {
    var appKey              : String {
        get {
            return QCallKit.sharedInstance.config.appKey
        }
    }
    
    var callSession : QCallSession?  {
        get {
            return CallManager.shared.callSession!
        }
    }
    
    var callStats           : [String : Any]?
    var appClient           : AgoraClient?      = nil
    var localVideo          : ((_ view: UIView)->())?
    var remoteVideo         : UIView?           = UIView()
    var dialingTime         : Double            = 45
    var reconnectTime       : Double            = 20
    var timerReconnect      : Timer             = Timer()
    var startDialTime       : String            = ""
    var stats               : [String : Any]?   = [String : Any]()
    var rxQuality: String    = ""
    var txQuality: String    = ""
    
    var inCallVC: UIViewController?
    
    func startCall(callDelegate: AgoraCallDelegate) {
        let room    = self.callSession!.roomId
        let content = self.callSession!.callRequest?.mode == .video
        self.appClient = AgoraClient.init(delegate: callDelegate , appKey: self.appKey, room: room, video: content)
    }
    
    // After click end call and close call connection
    func leaveCall() {
        self.appClient?.leaveChannel()
    }
    
    // finish call
    func endCall() {
        self.appClient?.leaveChannel()
    }
    
    func checkRoom() {
//            self.appClient?.
    }
    
    func reject(){
        self.appClient?.leaveChannel()
    }
    
    func setupLocalVideo(_ videoView: UIView) {
        self.appClient?.setupLocalVideo(videoView)
    }
    
    func setupRemoteVideo(_ videoView: UIView) {
        self.appClient?.setupRemoteVideo(videoView)
    }

    func setVideo(enable: Bool) {
        self.appClient?.setVideo(enable)
        _  = [CallTrackingEvents.IS_PAUSEVIDEO : enable]
    }
    
    func setSpeaker(enable: Bool) {
        self.appClient?.setSpeaker(enable)
    }
    
    func setMicrophone(enable: Bool) {
        self.appClient?.setMicrophone(enable)
        _  = [CallTrackingEvents.IS_MUTE:enable]
    }
    
    func toggleCamera() {
        self.appClient?.toggleCamera()
    }
    
    func checkReconnect() {
        if !self.timerReconnect.isValid {
            CallSoundManager.sharedInstance.reconnectTone()
            self.timerReconnect = Timer.scheduledTimer(timeInterval: self.reconnectTime, target: self, selector: #selector(self.stopReconnectTime), userInfo: nil, repeats: false)
        }
    }
    
    @objc func stopReconnectTime() {
        self.timerReconnect.invalidate()
    }
    
}


