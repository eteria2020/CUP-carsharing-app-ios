//
//  SpeechController.swift
//  Sharengo
//
//  Created by Dedecube on 30/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Speech
import UIKit
import Boomerang
import Action
import RxSwift

enum SpeechErrorType {
    case empty
    case authDenied
    case authRestricted
    case authNotDetermined
    case notSetted
    case notAvailable
    
    func getMessage() -> String {
        switch self {
        case .empty:
            return ""
        case .authDenied:
            return "alert_searchBarAuthDenied".localized()
        case .authRestricted:
            return "alert_searchBarAuthRestricted".localized()
        case .authNotDetermined:
            return "alert_searchBarAuthNotDetermined".localized()
        case .notSetted:
            return "alert_searchBarNotSetted".localized()
        case .notAvailable:
            return "alert_searchBarNotAvailable".localized()
        }
    }
    
    func showSettings() -> Bool {
        switch self {
        case .empty:
            return false
        case .authDenied:
            return true
        case .authRestricted:
            return false
        case .authNotDetermined:
            return true
        case .notSetted:
            return false
        case .notAvailable:
            return false
        }
    }
    
    func hideButton() -> Bool {
        switch self {
        case .empty:
            return true
        case .authDenied:
            return true
        case .authRestricted:
            return true
        case .authNotDetermined:
            return true
        case .notSetted:
            return false
        case .notAvailable:
            return false
        }
    }
}

@available(iOS 10.0, *)
class SpeechController: NSObject
{
    // TODO: ???
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "it-IT"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var speechTranscription: Variable<String?> = Variable(nil)
    var speechError: Variable<SpeechErrorType?> = Variable(nil)
    var isAuthorized:Bool {
        get {
            return SFSpeechRecognizer.authorizationStatus() == .authorized && AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.granted
        }
    }
    
    func requestSpeechAuthorization()
    {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                self.requestMicrophoneAuthorization()
            case .denied:
                if UserDefaults.standard.bool(forKey: "alertSpeechRecognizer") {
                    self.speechError.value = .authDenied
                } else {
                    UserDefaults.standard.set(true, forKey: "alertSpeechRecognizer")
                    self.speechError.value = .empty
                }
            case .restricted:
                if UserDefaults.standard.bool(forKey: "alertSpeechRecognizer") {
                    self.speechError.value = .authRestricted
                } else {
                    UserDefaults.standard.set(true, forKey: "alertSpeechRecognizer")
                    self.speechError.value = .empty
                }
            case .notDetermined:
                if UserDefaults.standard.bool(forKey: "alertSpeechRecognizer") {
                    self.speechError.value = .authNotDetermined
                } else {
                    UserDefaults.standard.set(true, forKey: "alertSpeechRecognizer")
                    self.speechError.value = .empty
                }
            }
        }
    }
    
    func requestMicrophoneAuthorization() {
        AVAudioSession.sharedInstance().requestRecordPermission { (success) in
            switch AVAudioSession.sharedInstance().recordPermission() {
            case AVAudioSessionRecordPermission.granted:
                self.manageRecording()
            case AVAudioSessionRecordPermission.denied:
                if UserDefaults.standard.bool(forKey: "alertMicrophone") {
                    self.speechError.value = .authDenied
                } else {
                    UserDefaults.standard.set(true, forKey: "alertMicrophone")
                    self.speechError.value = .empty
                }
            case AVAudioSessionRecordPermission.undetermined:
                if UserDefaults.standard.bool(forKey: "alertMicrophone") {
                    self.speechError.value = .authNotDetermined
                } else {
                    UserDefaults.standard.set(true, forKey: "alertMicrophone")
                    self.speechError.value = .empty
                }
            default:
                break
            }
        }
    }
    
    func manageRecording()
    {
        if self.audioEngine.isRunning {
            // Terminiamo l'ascolto
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
        } else {
            // Avviamo l'ascolto
            startRecording()
        }
    }
    
    fileprivate func startRecording() {
        self.speechRecognizer?.delegate = self
        if self.recognitionTask != nil {
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            self.speechError.value = .notSetted
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = audioEngine.inputNode else {
            self.speechError.value = .notSetted
            return
        }
        guard let recognitionRequest = recognitionRequest else {
            self.speechError.value = .notSetted
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false
            if result != nil {
                self.speechTranscription.value = result?.bestTranscription.formattedString ?? nil
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        self.audioEngine.prepare()
        do {
            try self.audioEngine.start()
        } catch {
            self.speechError.value = .notSetted
        }
    }
}

@available(iOS 10.0, *)
extension SpeechController: SFSpeechRecognizerDelegate
{
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        self.speechError.value = .notAvailable
        self.manageRecording()
    }
}
