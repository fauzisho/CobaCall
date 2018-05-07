//
//  CallToneManager.swift
//  QCall
//
//  Created by asharijuang on 5/9/17.
//  Copyright © 2017 qiscus. All rights reserved.
//

import Foundation
import AVFoundation

class CallSoundManager {
    
    ///Audio player responsible for playing sound files.
    var audioPlayer: AVAudioPlayer?
    
    private static let instance = CallSoundManager()
    public static var sharedInstance:CallSoundManager {
        get {
            return instance
        }
    }
    
    func incomingTone() {
        let url = URL(fileURLWithPath: QCallKit.bundle.path(forResource: "incoming", ofType: "caf")!)
        self.playSound(url, loop: true)
    }
    
    func dialingTone() {
        let url = URL(fileURLWithPath: QCallKit.bundle.path(forResource: "dialing", ofType: "mp3")!)
        self.playSound(url, loop: true, internalSpeaker : true)
    }
    
    func reconnectTone() {
        let url = URL(fileURLWithPath: QCallKit.bundle.path(forResource: "dialing", ofType: "mp3")!)
        self.playSound(url, loop: true)
    }
    
    // audio player
    func stop() {
        if self.audioPlayer != nil {
            if (self.audioPlayer?.isPlaying)! {
                self.audioPlayer?.stop()
                self.audioPlayer?.prepareToPlay()
                print("stop ringtone")
            }
        }
    }
    
    private func playSound(_ url: URL, loop: Bool = false,internalSpeaker : Bool = false) {
        //Play the sound
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil)
            if (internalSpeaker) {
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            }else{
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            }
            self.audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            if loop {
                print("play sound loop")
                audioPlayer?.numberOfLoops = -1
            }
        } catch {
            debugPrint("error call tone \(error)")
        }
    }
    
}
