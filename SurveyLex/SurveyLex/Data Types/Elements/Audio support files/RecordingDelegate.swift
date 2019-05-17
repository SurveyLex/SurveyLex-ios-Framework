//
//  RecordingDelegate.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/14.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

protocol RecordingDelegate {
    
    /// Called when recording has begun.
    func didBeginRecording(_ sender: RecordButton)
    
    /// Called when the recording button has finished recording.
    func didFinishRecording(_ sender: RecordButton, duration: Double)
    
    /// Error handling. This method could be called before recording began (i.e. lack of mic access) or during recording (i.e. interruption such as pressing the home button while recording).
    func didFailToRecord(_ sender: RecordButton, error: Recorder.Error)
}
