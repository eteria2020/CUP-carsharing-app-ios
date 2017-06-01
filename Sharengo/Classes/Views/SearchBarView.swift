//
//  SearchBarView.swift
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

class SearchBarView : UIView {
    @IBOutlet fileprivate weak var view_background: UIView!
    @IBOutlet fileprivate weak var icn_search: UIImageView!
    @IBOutlet fileprivate weak var view_microphone: UIView!
    @IBOutlet fileprivate weak var btn_microphone: UIButton!
    @IBOutlet fileprivate weak var view_search: UIView!
    @IBOutlet fileprivate weak var txt_search: UITextField!
    
    var viewModel: SearchBarViewModel?
    fileprivate var view: UIView!
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SearchBarViewModel else {
            return
        }
        self.viewModel = viewModel
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        viewModel.reload()
        xibSetup()
    }
   
    // MARK: - View methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        self.layoutIfNeeded()
        self.view_background.backgroundColor = Color.searchBarBackground.value
        self.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
        self.btn_microphone.layer.cornerRadius = self.btn_microphone.frame.size.width/2
        self.btn_microphone.layer.masksToBounds = true
        self.txt_search.attributedPlaceholder = NSAttributedString(string:"lbl_searchBarTextField".localized(), attributes:[NSForegroundColorAttributeName: Color.searchBarTextFieldPlaceholder.value, NSFontAttributeName: Font.searchBarTextFieldPlaceholder.value])
        self.updateInterface()
        guard let viewModel = viewModel else {
            return
        }
        viewModel.speechInProgress.asObservable()
            .subscribe(onNext: {[weak self] (speechInProgress) in
                DispatchQueue.main.async {
                    if speechInProgress {
                        self?.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophoneSpeechInProgress.value
                    } else {
                        self?.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
                    }
                }
            }).addDisposableTo(disposeBag)
        viewModel.speechTranscription.asObservable()
            .subscribe(onNext: {[weak self] (speechTransition) in
                DispatchQueue.main.async {
                    self?.txt_search.text = speechTransition ?? ""
                }
            }).addDisposableTo(self.disposeBag)
        viewModel.hideButton.asObservable()
            .subscribe(onNext: {[weak self] (hideButton) in
                DispatchQueue.main.async {
                    if hideButton {
                        self?.view_microphone.alpha = 0.5
                    } else {
                        self?.view_microphone.alpha = 1.0
                    }
                }
            }).addDisposableTo(self.disposeBag)
        self.btn_microphone.rx.bind(to: viewModel.selection, input: .dictated)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let nib = ViewXib.searchBar.getNib()
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.view_background.point(inside: convert(point, to: self.view_background), with: event) {
            return true
        }
        return false
    }
    
    func updateInterface() {
        guard let viewModel = viewModel else {
            return
        }
        if #available(iOS 10.0, *) {
            self.view_microphone.isHidden = false
            if (UserDefaults.standard.bool(forKey: "alertSpeechRecognizerRequestAuthorization") || UserDefaults.standard.bool(forKey: "alertMicrophoneRequestAuthorization")) && !viewModel.dictatedIsAuthorized() {
                self.view_microphone.alpha = 0.5
            } else {
                self.view_microphone.alpha = 1.0
            }
        } else {
            self.view_microphone.isHidden = true
        }
    }
    
    // MARK: - Data methods
    
    fileprivate func stopRequest() {
        self.viewModel?.stopRequest()
    }
    
    fileprivate func getResults(text: String) {
        self.stopRequest()
        self.viewModel?.reloadResults(text: text)
    }
}

extension SearchBarView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        let text = (textField.text! as NSString).replacingCharacters(in: range, with:string)
        self.getResults(text: text)
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        self.txt_search.resignFirstResponder()
        return true
    }
}
