//
//  MCallSession.swift
//  Madura
//
//  Created by ashari juang on 29/12/16.
//  Copyright © 2016 mhealth. All rights reserved.
//

import UIKit
import SwiftyJSON

public class QCallSession {
    public var roomId       : String?
    public var duration     : Int?
    public var endReason    : EndCallReasons?
    public var callRequest  : QCallRequest?
}

public class QCallRequest: NSObject {
    public var name    : String?
    public var avatar    : String?
    public var mode: QCallContent = .audio
    public var callType: QCallType = .outgoing
    public var userInfo : [String : Any]?
    
    public init(name:String, avatar: String?, callMode: QCallContent, callType: QCallType, userInfo: [String : Any]? = nil) {
        super.init()
        self.name       = name
        self.avatar     = avatar
        self.mode       = callMode
        self.callType   = callType
        self.userInfo   = userInfo
    }
}

public enum QCallContent {
    case audio
    case video
}

public enum QCallType {
    case incoming
    case outgoing
}
