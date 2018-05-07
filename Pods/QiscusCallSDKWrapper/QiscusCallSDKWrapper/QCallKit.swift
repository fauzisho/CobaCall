//
//  MaduraKit.swift
//  Madura
//
//  Created by ashari juang on 28/12/16.
//  Copyright © 2016 mhealth. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

public class QCallKit : NSObject {
    
    var manager  : CallManager?     = CallManager.shared
    var config      : QCallConfig!      = nil
    var isInActiveCall : Bool = false
    
    private static let instance = QCallKit()
    
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(returnActiveCall), name: Notification.Name(rawValue: "kReturnActiveCallOnWindow"), object: nil)

    }
    
    public static var sharedInstance:QCallKit {
        get {
            return instance
        }
    }
    
    public func setTimeoutFor(requestInterval: Int = 30, reconnectInterval: Int = 30) {
        self.manager?.requestTimeOut = requestInterval
        self.manager?.reconnectTimeout = reconnectInterval
    }
    
   func setInActiveCall(_ acticeCall : Bool) -> Void {
        UserDefaults.standard.set(acticeCall, forKey: "ISINACTIVECALL")

        UserDefaults.standard.synchronize()
        isInActiveCall = acticeCall
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"kCallStatusCheck"), object: nil, userInfo: nil)
    }
    
    
    @objc public func returnActiveCall() -> Void {
        if (manager?.callVC != nil) {
            let target = UIApplication.currentViewController()
            target?.navigationController?.present((manager?.callVC!)!, animated: true, completion: nil)
        }else{
            //print("There is no active call")
        }

    }
    
    public func getCallJoinStatus() -> Bool {
        return self.isInActiveCall
    }
    
    public func setup(withConfig config: QCallConfig) {
        QCallKit.sharedInstance.config     = config
    }
    
    public func startCall(request:QCallRequest, room: String, endCallHandler: @escaping (QCallSession) -> Void) {
        self.manager?.startCall(request: request, room: room, endCallHandler: endCallHandler)
    }
    
    public func terminate() {
        self.manager?.callVC?.autoEndCall()
    }
    
    class var bundle: Bundle {
        get {
            let podBundle = Bundle(for: self)
            
            if let bundleURL = podBundle.url(forResource: "QiscusCallSDKWrapper", withExtension: "bundle") {
                return Bundle(url: bundleURL)!
            }else {
                return podBundle
            }
        }
    }
}

extension String {

    func toBase64()->String{
        
        let data = self.data(using: String.Encoding.utf8)
        
        return data!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
    }
    
    var localized: String {

        return NSLocalizedString(self, tableName: nil, bundle: QCallKit.bundle, value: "", comment: "")

    }
}

extension UIApplication {
    
    // Get current view controller
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return currentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
    }
}
