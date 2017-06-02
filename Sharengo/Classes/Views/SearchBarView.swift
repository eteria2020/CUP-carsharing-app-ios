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

class SearchBarView : UIView, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_background: UIView!
    @IBOutlet fileprivate weak var icn_search: UIImageView!
    @IBOutlet fileprivate weak var view_microphone: UIView!
    @IBOutlet fileprivate weak var btn_microphone: UIButton!
    @IBOutlet fileprivate weak var view_search: UIView!
    @IBOutlet fileprivate weak var txt_search: UITextField!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var viewModel: SearchBarViewModel?
    fileprivate var view: UIView!
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SearchBarViewModel else {
            return
        }
        self.viewModel = viewModel
        xibSetup()
        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        viewModel.reload()
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
        self.collectionView.isHidden = true
        self.collectionView.backgroundColor = Color.searchBarResultBackground.value
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
                    if speechTransition != nil && self?.viewModel?.speechInProgress.value == true {
                        self?.viewModel?.reloadResults(text: speechTransition ?? "")
                    }
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
        if self.collectionView.point(inside: convert(point, to: self.collectionView), with: event) && txt_search.isFirstResponder {
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
    
    func updateCollectionView(show: Bool) {
        // TODO: ???
        if show {
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                self.viewModel?.reload()
                self.collectionView?.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView.isHidden = true
                self.endEditing(true)
                self.viewModel?.reload()
                self.collectionView?.reloadData()
            }
        }
    }
    
    func stopSearchBar() {
        self.endEditing(true)
    }
    
    // MARK: - Data methods
    
    fileprivate func stopRequest() {
        self.viewModel?.stopRequest()
    }
    
    fileprivate func getResults(text: String) {
        self.stopRequest()
        self.viewModel?.reloadResults(text: text)
    }
    
    // MARK: - Collection methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
}

extension SearchBarView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.updateCollectionView(show: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            if self.viewModel?.itemSelected == false {
                self.viewModel?.speechTranscription.value = ""
                self.viewModel?.getHistoryAndFavorites()
                self.updateCollectionView(show: false)
            }
            textField.resignFirstResponder()
            return false
        }
        let text = (textField.text! as NSString).replacingCharacters(in: range, with:string)
        self.viewModel?.itemSelected = false
        self.getResults(text: text)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.viewModel?.itemSelected == false {
            self.viewModel?.speechTranscription.value = ""
            self.viewModel?.getHistoryAndFavorites()
            self.updateCollectionView(show: false)
        }
    }
}
