//
//  CallSDK.swift
//  CobaCall
//
//  Created by UziApel on 04/05/18.
//  Copyright © 2018 qiscus. All rights reserved.
//

import Foundation
import UIKit
import QiscusCallSDKWrapper

class CallSDK: NSObject {
    
    static var sharedInstance  = CallSDK()
    var callClient = QCallKit.sharedInstance
    
    func setup() {
        
        let key            = "89ee51cbe6354619b46a6d03c8472254"
        
        self.callClient.setup(withConfig: QCallConfig.init(appID: "", appKey: key))
    }
    
    func call(WithUser user: String, video: Bool = true) {
        let request : QCallRequest?
        if video {
            request = QCallRequest.init(name: "hello", avatar: "http://", callMode: .video, callType: QCallType.outgoing)
        }else {
            request = QCallRequest.init(name: "hello", avatar: "http://", callMode: .audio, callType: QCallType.outgoing)
        }
        
        self.callClient.startCall(request: request!, room: user, endCallHandler: self.localEndCallAction(callSession:))
    }
    
    func receiveCall(WithUser user: String) {
        let request = QCallRequest.init(name: "hello", avatar: "http://", callMode: .video, callType: QCallType.outgoing)
        self.callClient.startCall(request: request, room: user, endCallHandler: self.localEndCallAction(callSession:))
    }
    
    // QCall hooks - called for local client end actions
    func localEndCallAction(callSession: QCallSession) {
        
        
    }
}
