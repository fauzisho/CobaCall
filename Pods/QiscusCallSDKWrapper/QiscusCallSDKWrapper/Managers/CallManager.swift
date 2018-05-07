//
//  CallManager.swift
//  Pods
//
//  Created by asharijuang on 5/11/17.
//
//

import Foundation

class CallManager {
    
    private static let instance = CallManager()
    public static var shared:CallManager {
        get {
            return instance
        }
    }
    
    var callSession     : QCallSession?         = nil
    var callClient      : QCallClient?          = nil
    
    var callVC:CallVC?
    public var requestTimeOut: Int      = 40 // second
    public var reconnectTimeout: Int    = 10 // second
    public var waitingTimeout: Int      = 45 // second
    var callTimer:Timer?
    
    public func startCall(request:QCallRequest, room: String = "", endCallHandler: @escaping (QCallSession) -> Void) {
        self.callClient             = QCallClient()
        self.callSession            = QCallSession()
        callSession?.callRequest    = request
        if room.isEmpty {
            callSession?.roomId     = request.name! + "_" + self.timeNow()
        }else {
            callSession?.roomId     = room
        }
        callSession?.duration       = 0
        callVC = CallVC()
        callVC?.endCallActionHandler = endCallHandler
        
        if(request.callType == .outgoing) {
            if(request.mode == .audio) {
                UIDevice.current.isProximityMonitoringEnabled = true
            }
            self.callClient?.startCall(callDelegate: callVC!)
        }
        
        let target  = UIApplication.currentViewController()
        target?.navigationController?.present(callVC!, animated: true, completion: nil)
    }
    
    // ==========================
    func timeNow() -> String {
        let f:DateFormatter = DateFormatter()
        f.timeZone = NSTimeZone.local
        f.dateFormat = "HH:mm:ss"
        return f.string(from: NSDate() as Date)
    }
    
    func timeDiff(dateStr:String) -> Int {
        let f:DateFormatter = DateFormatter()
        f.timeZone = NSTimeZone.local
        f.dateFormat = "HH:mm:ss"
        
        let now = f.string(from: NSDate() as Date)
        let startDate = f.date(from: dateStr)
        let endDate = f.date(from: now)
        let calendar: NSCalendar = NSCalendar.current as NSCalendar
        
        let calendarUnits   = NSCalendar.Unit.second
        let dateComponents  = calendar.components(calendarUnits, from: startDate!, to: endDate!, options: NSCalendar.Options.matchFirst)
        
        let sec = dateComponents.second
        
        return sec!;
    }
}
