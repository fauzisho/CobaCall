//
//  MCallSummary.swift
//  Madura
//
//  Created by ashari juang on 29/12/16.
//  Copyright © 2016 mhealth. All rights reserved.
//

import UIKit

public enum QCallFinishReason : String {
    case Hangup         = "Hangup"
    case EndCall        = "EndCall"
    case CancelCall     = "CancelCall"
    case RejectCall     = "RejectCall"
    case Unavailable    = "Unavailable"
}

public class QCallSummary: NSObject {
    public var reason   : QCallFinishReason?
    public var session  : QCallRequest?
}
