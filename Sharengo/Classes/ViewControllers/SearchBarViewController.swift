//
//  SearchBarViewController.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Action

class SearchBarViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_background: UIView!
    @IBOutlet fileprivate weak var icn_search: UIImageView!
    // TODO: ???
    @IBOutlet weak var view_microphone: UIView!
    @IBOutlet weak var btn_microphone: UIButton!
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var txt_search: UITextField!
    
    var viewModel: SearchBarViewModel?
    @available(iOS 10.0, *)
    fileprivate lazy var speechController = SpeechController()
    fileprivate var speechInProgress = false
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SearchBarViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .viewModel(let viewModel):
                Router.from(self,viewModel: viewModel).execute()
            }
        }).addDisposableTo(self.disposeBag)
        viewModel.reload()
    }
   
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view_background.backgroundColor = Color.searchBarBackground.value
        self.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
        self.btn_microphone.layer.cornerRadius = self.btn_microphone.frame.size.width/2
        self.btn_microphone.layer.masksToBounds = true
        self.txt_search.attributedPlaceholder = NSAttributedString(string:"lbl_searchBarTextField".localized(), attributes:[NSForegroundColorAttributeName: Color.searchBarTextFieldPlaceholder.value, NSFontAttributeName: Font.searchBarTextFieldPlaceholder.value])
        self.updateInterface()
    }
    
    func updateInterface() {
        if #available(iOS 10.0, *) {
            self.view_microphone.isHidden = false
            if (UserDefaults.standard.bool(forKey: "alertSpeechRecognizerRequestAuthorization") || UserDefaults.standard.bool(forKey: "alertMicrophoneRequestAuthorization")) && speechController.isAuthorized == false {
                self.view_microphone.alpha = 0.5
            } else {
                self.view_microphone.alpha = 1.0
            }
        } else {
            self.view_microphone.isHidden = true
        }
    }
    
    // MARK: - TextField methods
    
    func startSearching() {
        self.txt_search.becomeFirstResponder()
    }
    
    // MARK: - Data methods
    
    fileprivate func stopRequest() {
        self.viewModel?.stopRequest()
    }
    
    fileprivate func getResults(text: String) {
        self.stopRequest()
        self.viewModel?.reloadResults(text: text)
    }
    
    // MARK: - Microphone methods
    
    func toggleDictated() {
        if #available(iOS 10.0, *) {
            if speechInProgress {
                self.speechInProgress = false
                self.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
                speechController.manageRecording()
            } else {
                self.speechInProgress = true
                self.speechController.requestSpeechAuthorization()
                self.speechController.speechInProgress.asObservable()
                    .subscribe(onNext: {[weak self] (speechInProgress) in
                        DispatchQueue.main.async {
                            if speechInProgress {
                                self?.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophoneSpeechInProgress.value
                            } else {
                                self?.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
                            }
                        }
                    }).addDisposableTo(disposeBag)
                self.speechController.speechTranscription.asObservable()
                    .subscribe(onNext: {[weak self] (speechTransition) in
                        DispatchQueue.main.async {
                            self?.txt_search.text = speechTransition ?? ""
                        }
                    }).addDisposableTo(disposeBag)
                self.speechController.speechError.asObservable()
                    .subscribe(onNext: { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                self.speechInProgress = false
                                self.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
                                if error.hideButton() {
                                    self.view_microphone.alpha = 0.5
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
                    }).addDisposableTo(disposeBag)
            }
        }
    }
}

extension SearchBarViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if string == "\n"
//        {
//            textField.resignFirstResponder()
//        }
//        else
//        {
            let text = (textField.text! as NSString).replacingCharacters(in: range, with:string)
            self.getResults(text: text)
        
//        }
        
        return true
    }
}
