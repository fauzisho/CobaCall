//
//  ViewController.swift
//  CobaCall
//
//  Created by UziApel on 04/05/18.
//  Copyright © 2018 qiscus. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    var callSdk = CallSDK()
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }

    @IBAction func videoButton(_ sender: Any) {
        callSdk.call(WithUser: textField.text!)
    }
    @IBAction func audioButton(_ sender: Any) {
    callSdk.call(WithUser: textField.text!, video: false)
    }
    
    @IBAction func reciveCall(_ sender: Any) {
          callSdk.receiveCall(WithUser: textField.text!)
    }
}

