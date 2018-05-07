//
//  File.swift
//  Pods
//
//  Created by asharijuang on 5/8/17.
//
//

import Foundation

public class QCallConfig {

    internal var appID      : String
    internal var appKey     : String
    
    public init(appID id: String, appKey: String) {
        self.appID      = id
        self.appKey     = appKey
    }
}
