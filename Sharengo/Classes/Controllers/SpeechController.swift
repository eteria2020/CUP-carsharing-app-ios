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
    case authSpeechAuthorizationDenied
    case authSpeechAuthorizationRestricted
    case authSpeechAuthorizationNotDetermined
    case authMicrophoneDenied
    case authMicrophoneUndetermined
    case notSetted
    case notAvailable
    
    func getMessage() -> String {
        switch self {
        case .empty:
            return ""
        case .authSpeechAuthorizationDenied:
            return "alert_searchBarAuthSpeechAuthorizationDenied".localized()
        case .authSpeechAuthorizationRestricted:
            return "alert_searchBarAuthSpeechAuthorizationRestricted".localized()
        case .authSpeechAuthorizationNotDetermined:
            return "alert_searchBarAuthSpeechAuthorizationNotDetermined".localized()
        case .authMicrophoneDenied:
            return "alert_searchBarAuthMicrophoneDenied".localized()
        case .authMicrophoneUndetermined:
            return "alert_searchBarAuthMicrophoneUndetermined".localized()
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
        case .authSpeechAuthorizationDenied:
            return true
        case .authSpeechAuthorizationRestricted:
            return false
        case .authSpeechAuthorizationNotDetermined:
            return true
        case .authMicrophoneDenied:
            return true
        case .authMicrophoneUndetermined:
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
        case .authSpeechAuthorizationDenied:
            return true
        case .authSpeechAuthorizationRestricted:
            return true
        case .authSpeechAuthorizationNotDetermined:
            return true
        case .authMicrophoneDenied:
            return true
        case .authMicrophoneUndetermined:
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
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "lcl_searchBarSpeechRecognizer".localized()))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var speechInProgress: Variable<Bool> = Variable(false)
    var speechTranscription: Variable<String?> = Variable(nil)
    var speechError: Variable<SpeechErrorType?> = Variable(nil)
    var isAuthorized:Bool {
        get {
            return SFSpeechRecognizer.authorizationStatus() == .authorized && AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.granted
        }
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            UserDefaults.standard.set(true, forKey: "alertSpeechRecognizerRequestAuthorization")
            switch authStatus {
            case .authorized:
                self.requestMicrophoneAuthorization()
            case .denied:
                if UserDefaults.standard.bool(forKey: "alertSpeechRecognizer") {
                    self.speechError.value = .authSpeechAuthorizationDenied
                } else {
                    UserDefaults.standard.set(true, forKey: "alertSpeechRecognizer")
                    self.speechError.value = .empty
                }
            case .restricted:
                if UserDefaults.standard.bool(forKey: "alertSpeechRecognizer") {
                    self.speechError.value = .authSpeechAuthorizationRestricted
                } else {
                    UserDefaults.standard.set(true, forKey: "alertSpeechRecognizer")
                    self.speechError.value = .empty
                }
            case .notDetermined:
                if UserDefaults.standard.bool(forKey: "alertSpeechRecognizer") {
                    self.speechError.value = .authSpeechAuthorizationNotDetermined
                } else {
                    UserDefaults.standard.set(true, forKey: "alertSpeechRecognizer")
                    self.speechError.value = .empty
                }
            }
        }
    }
    
    func requestMicrophoneAuthorization() {
        UserDefaults.standard.set(true, forKey: "alertMicrophoneRequestAuthorization")
        AVAudioSession.sharedInstance().requestRecordPermission { (success) in
            switch AVAudioSession.sharedInstance().recordPermission() {
            case AVAudioSessionRecordPermission.granted:
                self.manageRecording()
            case AVAudioSessionRecordPermission.denied:
                if UserDefaults.standard.bool(forKey: "alertMicrophone") {
                    self.speechError.value = .authMicrophoneDenied
                } else {
                    UserDefaults.standard.set(true, forKey: "alertMicrophone")
                    self.speechError.value = .empty
                }
            case AVAudioSessionRecordPermission.undetermined:
                if UserDefaults.standard.bool(forKey: "alertMicrophone") {
                    self.speechError.value = .authMicrophoneUndetermined
                } else {
                    UserDefaults.standard.set(true, forKey: "alertMicrophone")
                    self.speechError.value = .empty
                }
            default:
                break
            }
        }
    }
    
    func manageRecording() {
        if self.audioEngine.isRunning {
            self.speechInProgress.value = false
            // Terminiamo l'ascolto
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
        } else {
            // Avviamo l'ascolto
            startRecording()
        }
    }
    
    fileprivate func startRecording() {
        audioEngine.inputNode?.removeTap(onBus: 0)
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
                isFinal = (result?.isFinal)!
                if self.speechInProgress.value == true {
                    self.speechTranscription.value = result?.bestTranscription.formattedString ?? nil
                }
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
            self.speechInProgress.value = true
            try self.audioEngine.start()
        } catch {
            self.speechError.value = .notSetted
        }
    }
}

@available(iOS 10.0, *)
extension SpeechController: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        self.speechInProgress.value = false
        self.speechError.value = .notAvailable
        self.manageRecording()
    }
}
