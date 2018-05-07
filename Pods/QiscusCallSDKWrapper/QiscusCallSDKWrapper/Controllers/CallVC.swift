//
//  CallVC.swift
//  QCall
//
//  Created by asharijuang on 6/7/17.
//  Copyright © 2017 qiscus. All rights reserved.
//

import UIKit
import AlamofireImage

public enum EndCallReasons:String {
    
    case mediaError = "MEDIA_ERROR"
    case missed = "TIMEOUT"    // Doctor does not answer/reject even after 45 mins
    
    case cancelled = "CANCELLED" // Doctor rejects(Doctor side) or Client rjects
    case networkError = "NETWORK_ERROR" // network error on client (OnConnectionLost), both doctor and patien
    case hungup = "HUNG_UP"  //During call
    
    case remoteHungup = "REMOTE_HUNG_UP" // Hangup in from remote side OnUserOffline (USER_OFFLINE_QUIT)
    case remoteNetworkError = "REMOTE_NETWORK_ERROR" //remote error OnUserOffline USER_OFFLINE_DROPPED
    case remoteCancelled = "REMOTE_CANCELLED"//   Equivalent of Rejected in the client side, before the call is started
    
}

class CallVC: UIViewController, UIGestureRecognizerDelegate {
    let kShowActiveCallOnWindow = "kShowActiveCallOnWindow"
    @IBOutlet weak var imageCallerBig: UIImageView!
    @IBOutlet weak var imageCallerSmall: UIImageView!
    @IBOutlet weak var videoBig: UIView!
    @IBOutlet weak var localVideoView: UIView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var callingLabel: UILabel!

    @IBOutlet var viewActionIncomingCall: UIView!

    @IBOutlet var viewActionVideoCall: UIView!
    @IBOutlet var viewActionAudioCall: UIView!

    // Action Button Audio Call
    @IBOutlet weak var buttonEndCallAudio: UIButton!
    @IBOutlet weak var buttonChatAudio: UIButton!
    @IBOutlet weak var buttonMicAudio: UIButton!
    @IBOutlet weak var buttonSpeakerAudio: UIButton!

    // Action Button Video Call
    @IBOutlet weak var buttonEndCallVideo: UIButton!
    @IBOutlet weak var buttonSwitchCamera: UIButton!
    @IBOutlet weak var buttonChatVideo: UIButton!
    @IBOutlet weak var buttonMicVideo: UIButton!

    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var localVideoBottomConstraint: NSLayoutConstraint!

    var callMode:String = "voice"
    var callDate : Date? = nil
    var timer : Timer? = nil
    var MISSED_CALL_TIMEOUT : Int = CallManager.shared.requestTimeOut
    var RECONNECT_CALL_TIMEOUT : Int = CallManager.shared.reconnectTimeout
    var OFFLINE_CALL_TIMEOUT : Int = CallManager.shared.reconnectTimeout
    var WAITING_CALL_TIMEOUT : Int = CallManager.shared.waitingTimeout
    var missedCallTimer:Timer?
    var reconnectingTimer:Timer?
    var offlineTimer:Timer?
    var waitingTimer:Timer?

    var tapToggleVideo: UITapGestureRecognizer?
    var actionBar : CGFloat = 0

    var hasJoined = false

    let soundManager = CallSoundManager.sharedInstance

    var endCallActionHandler: ((QCallSession) -> Void)? = nil

    var callClient : QCallClient {
        get {
            return CallManager.shared.callClient!
        }
    }

    var callSession : QCallSession?  {
        get {
            return CallManager.shared.callSession!
        }
    }

    var callRequest : QCallRequest?  {
        get {
            return CallManager.shared.callSession!.callRequest
        }
    }

    init() {
        let nibName:String = "CallVC"
        let nibBundle = Bundle(for: type(of: self))

        super.init(nibName: nibName, bundle: nibBundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        QCallKit.sharedInstance.setInActiveCall(hasJoined)
        self.navigationController?.isNavigationBarHidden    = true
        self.imageCallerSmall.layer.cornerRadius = self.imageCallerSmall.frame.size.height/2
        self.imageCallerSmall.clipsToBounds = true
        self.actionBar = -(self.viewHeader.frame.size.height + 25)
        if(self.callRequest?.mode == .audio) {
            callMode = "voice"
        }else {
            callMode = "video"
        }
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageCallerSmall.layer.cornerRadius = self.imageCallerSmall.frame.size.height/2
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let image = UIImage(named: "defaultprofilePic", in: QCallKit.bundle, compatibleWith: nil)
        if let url = URL(string: (self.callRequest?.avatar)!) {
            print("\(url)")
            self.imageCallerSmall.af_setImage(withURL: url, placeholderImage: image)
        }
        self.imageCallerSmall.layer.cornerRadius = self.imageCallerSmall.frame.size.height/2
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelOfflineTimer()
        cancelMissedCallTimer()
        cancelReconnectingTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func autoEndCall() {
        soundManager.stop()
        self.callSession?.endReason = .cancelled
        self.callClient.endCall()
        self.dismiss(animated: true, completion: nil)
        if ((self.timer) != nil) {
            self.timer?.invalidate()
            self.timer = nil;
        }
        hasJoined = false
        QCallKit.sharedInstance.setInActiveCall(hasJoined)
    }

    // Endcall or cancel
    @IBAction func clickEndCall(_ sender: Any) {
        soundManager.stop()
        self.callClient.endCall()
        self.dismiss(animated: true, completion: nil)
        UIDevice.current.isProximityMonitoringEnabled = false
        if(callDate == nil) {
            self.callSession?.endReason = .cancelled
            callSession?.duration = 0
            self.endCallActionHandler!(callSession!)
        }else {
            self.callSession?.endReason = EndCallReasons.hungup
            _ = Date().timeIntervalSince(self.callDate!)
            self.endCallActionHandler!(callSession!)
        }
        if ((self.timer) != nil) {
            self.timer?.invalidate()
            self.timer = nil;
        }
        hasJoined = false
        QCallKit.sharedInstance.setInActiveCall(hasJoined)
    }

    func cancelMissedCallTimer() {
        if missedCallTimer != nil {
            missedCallTimer?.invalidate()
            missedCallTimer = nil
        }
    }

    func cancelReconnectingTimer() {
        reconnectingTimer?.invalidate()
        reconnectingTimer = nil
    }

    func cancelOfflineTimer() {
        offlineTimer?.invalidate()
        offlineTimer = nil
    }

    func cancelWaitingTimer() {
        waitingTimer?.invalidate()
        waitingTimer = nil
    }

    // Accept
    @IBAction func clickAccept(_ sender: Any) {
        soundManager.stop()
        self.cancelMissedCallTimer()
        self.callClient.startCall(callDelegate: self)
        if(self.callRequest?.mode == .audio) {
            UIDevice.current.isProximityMonitoringEnabled = true
        }
        viewActionIncomingCall.removeFromSuperview()
        self.setupActionUI()
    }

    // Reject
    @IBAction func clickReject(_ sender: Any) {
        soundManager.stop()

        self.cancelMissedCallTimer()
        self.callClient.endCall()
        self.dismiss(animated: true, completion: nil)
        QCallKit.sharedInstance.setInActiveCall(false)
        self.callSession?.endReason = .cancelled
        self.endCallActionHandler!(callSession!)
    }

    // Call Content
    @IBAction func clickSwitchCamera(_ sender: Any) {
        self.callClient.toggleCamera()
    }

    @IBAction func clickMic(_ sender: Any) {

        if (callRequest?.mode == .video) {
            if(self.buttonMicVideo.isSelected == true){
                self.callClient.setMicrophone(enable: false)
                self.buttonMicVideo.isSelected = false
            }else {
                self.callClient.setMicrophone(enable: true)
                self.buttonMicVideo.isSelected = true
            }
        }else{
            if(self.buttonMicAudio.isSelected == true){
                self.callClient.setMicrophone(enable: false)
                self.buttonMicAudio.isSelected = false
            }else {
                self.callClient.setMicrophone(enable: true)
                self.buttonMicAudio.isSelected = true
            }
        }

    }

    @IBAction func clickSpeaker(_ sender: Any) {
        if(self.buttonSpeakerAudio.isSelected == true){
            self.callClient.setSpeaker(enable: false)
            self.buttonSpeakerAudio.isSelected = false
        }else {
            self.callClient.setSpeaker(enable: true)
            self.buttonSpeakerAudio.isSelected = true
        }
    }

    @IBAction func clickChat(_ sender: Any?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: self.kShowActiveCallOnWindow), object: nil)
        var rect = self.view.frame
        rect.origin.y += 44
        rect.size.height -= 44
        self.dismiss(animated: true) {};
    }

    // UI
    func setupUI() {
        self.labelName.text = self.callRequest?.name
        self.labelStatus.text = self.callRequest?.mode == .audio ? "VOICE_CALL".localized : "VIDEO_CALL".localized
        if self.callRequest?.callType == .incoming {
            self.cancelMissedCallTimer()
            missedCallTimer = Timer.scheduledTimer(timeInterval: TimeInterval(MISSED_CALL_TIMEOUT), target: self, selector: #selector(missedCallAction), userInfo: nil, repeats: false)
            soundManager.incomingTone()

            self.view.addSubview(self.viewActionIncomingCall)
            self.setupActionConstraint(target: self.viewActionIncomingCall)

            if (self.callRequest?.mode == .video) {
                // video call
                //self.imageCallerSmall.isHidden = true
               // self.callClient.setupLocalVideo(self.videoBig)
                self.localVideoView.isHidden = true
            }else {
                // audio call
                // disable loadspeaker
                self.callClient.setSpeaker(enable: false)
//                self.buttonSpeakerAudio.isSelected = true
            }
            self.callingLabel.text  = "INCOMING".localized
        }else{
            soundManager.dialingTone()
            self.cancelWaitingTimer()
            waitingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(OFFLINE_CALL_TIMEOUT), target: self, selector: #selector(autoEndCall), userInfo: nil, repeats: false)
            self.callingLabel.text  = "CALLING".localized
            self.setupActionUI()
        }
    }

    @objc func connectionLost() {
        self.callClient.endCall()
        self.dismiss(animated: true, completion: nil)
        QCallKit.sharedInstance.setInActiveCall(false)

        self.callSession?.endReason = EndCallReasons.networkError
        let callInterval = Date().timeIntervalSince(self.callDate!)
        self.callSession?.duration  = Int(callInterval)
        self.endCallActionHandler!(callSession!)
    }

    @objc func missedCallAction() {
        print("hitting missed")
        soundManager.stop()
        self.callClient.endCall()
        self.dismiss(animated: true, completion: nil)
        QCallKit.sharedInstance.setInActiveCall(false)

        self.callSession?.endReason = EndCallReasons.missed

        self.endCallActionHandler!(callSession!)
    }

    func getCurrentDateTime() -> String {
        let date = Date()
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)

        let time = "\(hour):\(minutes)"

        return time
    }

    func setupActionUI() {
        // Audio Call, Video Call, or Incoming Call
        if (self.callRequest?.mode == .video) {
            self.view.addSubview(self.viewActionVideoCall)
            self.imageCallerSmall.isHidden = true
            self.localVideoView.isHidden = true
            self.videoBig.isHidden = false
            self.callClient.setupLocalVideo(self.videoBig)
            self.setupActionConstraint(target: self.viewActionVideoCall)
        }else {
            self.view.addSubview(self.viewActionAudioCall)
            self.setupActionConstraint(target: self.viewActionAudioCall)
        }
    }

    @objc func showTimer() -> Void {
        let intervalDouble = Date().timeIntervalSince(self.callDate!)
        let interval = Int(intervalDouble)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        self.callingLabel.text = String(format: "%02d:%02d", minutes, seconds)
        //self.callingLabel.textAlignment = NSTextAlignment.left

    }



    func setupActionConstraint(target: UIView) {
        let horizonalContraints = NSLayoutConstraint(item: target, attribute:
            .leading, relatedBy: .equal, toItem: view,
                      attribute: .leading, multiplier: 1.0,
                      constant: 0)
        let horizonal2Contraints = NSLayoutConstraint(item: target, attribute:
            .trailing, relatedBy: .equal, toItem: view,
                       attribute: .trailing, multiplier: 1.0, constant: 0)

        let pinTop = NSLayoutConstraint(item: target, attribute: .top, relatedBy: .equal,
                                        toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        let pinBottom = NSLayoutConstraint(item: target, attribute: .bottom, relatedBy: .equal,
                                           toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        target.translatesAutoresizingMaskIntoConstraints   = false
        NSLayoutConstraint.activate([horizonalContraints, horizonal2Contraints, pinTop, pinBottom])
    }

    @objc func leaveChannel() {
        self.callClient.leaveCall()
        self.dismiss(animated: true, completion: nil)
        QCallKit.sharedInstance.setInActiveCall(false)

        _ = EndCallReasons.remoteNetworkError.rawValue
        _ = Date().timeIntervalSince(self.callDate!)
//        self.endCallActionHandler!((self.callRequest?.roomId)!,(self.callRequest?.conversationId)!,reason,callMode, Int(callInterval))
        self.endCallActionHandler!(callSession!)
    }

    // fullscreen
    @objc func toggleFullVideoCall() {
        if(self.headerViewTopConstraint.constant == 25.0){
            print("hide")
            UIView.animate(withDuration: 0.4, animations: {
                self.headerViewTopConstraint.constant = -self.actionBar
                self.localVideoBottomConstraint.constant = 20
                self.view.layoutIfNeeded()
                self.viewHeader.alpha = 0
                self.viewActionVideoCall.alpha = 0
            })

        }else{
            print("Show")
            UIView.animate(withDuration: 0.4, animations: {
               self.headerViewTopConstraint.constant = 25.0
                self.localVideoBottomConstraint.constant = 100
                self.view.layoutIfNeeded()
                self.viewHeader.alpha = 1.0
                self.viewActionVideoCall.alpha = 1.0

            })

        }

    }

}

extension CallVC: AgoraCallDelegate {

    func reportCallStats(_ info: [AnyHashable : Any]!) {
    }

    func didLeaveChannel(withInfo info: [AnyHashable : Any]!) {
    }

    func didOffline(ofUid reason: Int32) {

        if(reason == 1) {
            self.cancelOfflineTimer()
            offlineTimer = Timer.scheduledTimer(timeInterval: TimeInterval(OFFLINE_CALL_TIMEOUT), target: self, selector: #selector(leaveChannel), userInfo: nil, repeats: false)
        }else {

            self.callClient.leaveCall()
            self.dismiss(animated: true, completion: nil)
            QCallKit.sharedInstance.setInActiveCall(false)
            _ = EndCallReasons.remoteHungup.rawValue
            _ = Date().timeIntervalSince(self.callDate!)
//            self.endCallActionHandler!((self.callRequest?.roomId)!,(self.callRequest?.conversationId)!,reason,callMode, Int(callInterval))
            self.endCallActionHandler!(callSession!)
        }
    }

    func connectionDidLost() {
        soundManager.reconnectTone()
        self.cancelReconnectingTimer()
        reconnectingTimer = Timer.scheduledTimer(timeInterval: TimeInterval(RECONNECT_CALL_TIMEOUT), target: self, selector: #selector(connectionLost), userInfo: nil, repeats: false)
    }

    func didRejoinChannel(_ channel: String!, withUid uid: UInt, elapsed: Int) {

        self.cancelOfflineTimer()
        self.cancelReconnectingTimer()

        if self.callRequest?.mode == .video {
            callClient.setSpeaker(enable: true)
            self.callClient.setupRemoteVideo(self.videoBig)
            // Animation Full Video call
            self.tapToggleVideo = UITapGestureRecognizer(target: self, action: #selector(self.toggleFullVideoCall))
            tapToggleVideo!.delegate = self
            self.view.addGestureRecognizer(tapToggleVideo!)
        }else{
            callClient.setSpeaker(enable: false)
        }
        hasJoined = true
        QCallKit.sharedInstance.setInActiveCall(hasJoined)
    }

    func didJoined(ofUid uid: UInt, elapsed: Int) {
        self.cancelWaitingTimer()
        hasJoined = true
        QCallKit.sharedInstance.setInActiveCall(hasJoined)
        soundManager.stop()
        callDate = Date()

        if (self.callRequest?.mode == .video) {
            self.callClient.setupRemoteVideo(self.videoBig)
            self.callClient.setupLocalVideo(self.localVideoView)
            self.localVideoView.isHidden = false
            // Animation Full Video call
            self.tapToggleVideo = UITapGestureRecognizer(target: self, action: #selector(self.toggleFullVideoCall))
            tapToggleVideo!.delegate = self
            self.view.addGestureRecognizer(tapToggleVideo!)
        }

        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showTimer), userInfo: nil, repeats: true)
    }


    func txQuality(_ txQuality: String!, rxQuality: String!) {

    }

    func didVideoMuted(_ mute :Bool) {
    }
}
