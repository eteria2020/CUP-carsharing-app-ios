//
//  SearchBarViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import ReachabilitySwift

enum SearchBarSelectionInput: SelectionInput {
    case item(IndexPath)
    case dictated
}
enum SearchBarSelectionOutput: SelectionOutput {
    case empty
    case viewModel(ViewModelType)
    case dictated
}

// TODO: bloccare la chiamata per evitare ri-caricamento dei dati
// TODO: la chiamata deve partire al terzo carattere
// TODO: visualizzare i risultati
// TODO: la ricerca viene chiamata dal riconoscimento vocale

final class SearchBarViewModel: ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder()
    var speechInProgress: Variable<Bool> = Variable(false)
    var speechTranscription: Variable<String?> = Variable(nil)
    var hideButton: Variable<Bool> = Variable(false)
    
    fileprivate var resultsDispose: DisposeBag?
    fileprivate var apiController: NominatimAPIController = NominatimAPIController()
    @available(iOS 10.0, *)
    fileprivate lazy var speechController = SpeechController()
    
    lazy var selection:Action<SearchBarSelectionInput,SearchBarSelectionOutput> = Action { input in
        return .empty()
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .dictated:
                if #available(iOS 10.0, *) {
                    if self.speechInProgress.value {
                        self.speechInProgress.value = false
                        self.speechController.manageRecording()
                    } else {
                        self.speechInProgress.value = true
                        self.speechController.requestSpeechAuthorization()
                        self.speechController.speechInProgress.asObservable()
                            .subscribe(onNext: {[weak self] (speechInProgress) in
                                DispatchQueue.main.async {
                                    self?.speechInProgress.value = speechInProgress
                                }
                            }).addDisposableTo(self.disposeBag)
                        self.speechController.speechTranscription.asObservable()
                            .subscribe(onNext: {[weak self] (speechTransition) in
                                DispatchQueue.main.async {
                                    self?.speechTranscription.value = speechTransition ?? ""
                                }
                            }).addDisposableTo(self.disposeBag)
                        self.speechController.speechError.asObservable()
                            .subscribe(onNext: { (error) in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        self.speechInProgress.value = false
                                        if error.hideButton() {
                                            self.hideButton.value = true
                                        }
                                        if error != .empty {
                                            if error.showSettings() == false {
                                                let dialog = ZAlertView(title: nil, message: error.getMessage(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                                    alertView.dismissAlertView()
                                                })
                                                dialog.allowTouchOutsideToDismiss = false
                                                dialog.show()
                                            } else {
                                                let dialog = ZAlertView(title: nil, message: error.getMessage(), isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                                                        okButtonHandler: { alertView in
                                                                            alertView.dismissAlertView()
                                                                            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                                                },
                                                                        cancelButtonHandler: { alertView in
                                                                            alertView.dismissAlertView()
                                                })
                                                dialog.allowTouchOutsideToDismiss = false
                                                dialog.show()
                                            }
                                        }
                                    }
                                }
                            }).addDisposableTo(self.disposeBag)
                    }
                }
                return .just(.dictated)
            default: break
            }
            return .just(.empty)
        }
    }
    
    // MARK: - Dictated methods
    
    func dictatedIsAuthorized() -> Bool {
        if #available(iOS 10.0, *) {
            return self.speechController.isAuthorized
        } else {
            return false
        }
    }
    
    // MARK: - Address methods
    
    func stopRequest() {
        self.resultsDispose = nil
        self.resultsDispose = DisposeBag()
    }
    
    func reloadResults(text: String) {
        self.apiController.searchAddress(text: text)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let addresses):
                    print(addresses)
                case .error(let error):
                    print(error)
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        var message = "lbl_generalError".localized()
                        if Reachability()?.isReachable == false {
                            message = "lbl_connectionError".localized()
                        }
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                    }
                default:
                    break
                }
            }.addDisposableTo(resultsDispose!)
    }
}
