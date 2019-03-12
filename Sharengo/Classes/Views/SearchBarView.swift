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

import Action
import DeviceKit

class SearchBarView : UIView, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_black: UIView!
    @IBOutlet fileprivate weak var view_background: UIView!
    @IBOutlet fileprivate weak var icn_search: UIImageView!
    @IBOutlet fileprivate weak var view_microphone: UIView!
    @IBOutlet fileprivate weak var btn_microphone: UIButton!
    @IBOutlet fileprivate weak var view_search: UIView!
    @IBOutlet fileprivate weak var txt_search: UITextField!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var btn_cleanSearch: UIButton!
   
    var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var viewModel: SearchBarViewModel?
    fileprivate var view: UIView!
    fileprivate var favourites: Bool = false
    
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
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
        self.layoutIfNeeded()
        self.view_black.alpha = 0.0
        self.collectionView.isHidden = true
        self.collectionView.backgroundColor = Color.searchBarResultBackground.value
        self.view_background.backgroundColor = Color.searchBarBackground.value
        self.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
        self.btn_microphone.layer.cornerRadius = self.btn_microphone.frame.size.width/2
        self.btn_microphone.layer.masksToBounds = true
        self.txt_search.attributedPlaceholder = NSAttributedString(string:"lbl_searchBarTextField".localized(), attributes:[NSAttributedString.Key.foregroundColor: Color.searchBarTextFieldPlaceholder.value, NSAttributedString.Key.font: Font.searchBarTextFieldPlaceholder.value])
        guard let viewModel = viewModel else {
            return
        }
        viewModel.speechInProgress.asObservable()
            .subscribe(onNext: {[weak self] (speechInProgress) in
                DispatchQueue.main.async {
                    if speechInProgress {
                        self?.txt_search.becomeFirstResponder()
                        self?.updateCollectionView(show: true)
                        self?.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophoneSpeechInProgress.value
                    } else {
                        self?.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
                    }
                }
            }).disposed(by: disposeBag)
        viewModel.speechTranscription.asObservable()
            .subscribe(onNext: {[weak self] (speechTransition) in
                DispatchQueue.main.async {
                    if self?.viewModel?.speechInProgress.value == true {
                        self?.txt_search.text = speechTransition ?? ""
                        if speechTransition != nil && self?.viewModel?.speechInProgress.value == true {
                            self?.viewModel?.stopRequest()
                            self?.viewModel?.reloadResults(text: speechTransition ?? "")
                        }
                    }
                }
            }).disposed(by: self.disposeBag)
        viewModel.hideButton.asObservable()
            .subscribe(onNext: {[weak self] (hideButton) in
                DispatchQueue.main.async {
                    if hideButton {
                        self?.view_microphone.alpha = 0.5
                    } else {
                        self?.view_microphone.alpha = 1.0
                    }
                }
            }).disposed(by: self.disposeBag)
        
        self.btn_cleanSearch.rx.tap.asObservable()
            .subscribe(onNext:{
                self.txt_search.text = ""
                self.btn_cleanSearch.isHidden = true
            }).disposed(by: disposeBag)
        
        self.btn_cleanSearch.rx.bind(to: viewModel.selection, input: .clean)
        switch Device().diagonal {
        case 3.5:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 119
        case 4:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 179
        case 4.7:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 259
        case 5.5:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 299
        case 5.8:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 300
        default:
            break
        }
        let dispatchTime = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.updateInterface()
        }
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
        if show {
            DispatchQueue.main.async {
                self.collectionView.isHidden = false
                self.viewModel?.reload()
                self.collectionView?.reloadData()
                self.collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: false)
            }
        } else {
            DispatchQueue.main.async {
                self.view_black.alpha = 0.0
                self.collectionView.isHidden = true
                self.endEditing(true)
                self.viewModel?.reload()
                self.collectionView?.reloadData()
                if self.favourites {
                    self.view_background.alpha = 0.0
                }
            }
        }
    }
    
    func stopSearchBar() {
        self.endEditing(true)
    }
    
    func setupForFavourites() {
        self.favourites = true
        self.viewModel?.favourites = true
        self.view_background.alpha = 0.0
    }
    
    func showSearchBar() {
        self.viewModel?.reloadResults(text: self.txt_search.text ?? "")
        switch Device().diagonal {
        case 3.5:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 70
        case 4:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 93
        case 4.7:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 98
        case 5.5:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 105
        case 5.8:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 108
        default:
            break
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view_background.alpha = 1.0
            self.view_black.alpha = 0.65
        }) { (success) in
            self.txt_search.becomeFirstResponder()
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
        let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        var height: CGFloat = 0.0
        switch Device().diagonal {
        case 3.5:
            height = 60.0
        case 4:
            height = 60.0
        case 4.7:
            height = 65.0
        case 5.5:
            height = 75.0
        case 5.8:
            height = 76.0
        default:
            break
        }
        let newSize = CGSize(width: size.width, height: height)
        return newSize
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
            }
            self.updateCollectionView(show: false)
            textField.resignFirstResponder()
            return false
        }
        if self.viewModel?.speechInProgress.value == true && self.viewModel?.itemSelected == false {
            self.viewModel?.selection.execute(.dictated)
            if #available(iOS 10.0, *) {
                self.viewModel?.speechController.speechTranscription.value = ""
            }
        }
        let text = (textField.text! as NSString).replacingCharacters(in: range, with:string)
        self.viewModel?.itemSelected = false
        self.getResults(text: text)
        if(text.isEmpty){
            btn_cleanSearch.isHidden = true
        }else{
            btn_cleanSearch.isHidden = false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.viewModel?.speechInProgress.value == true && self.viewModel?.itemSelected == false {
            self.viewModel?.selection.execute(.dictated)
        }
        if self.viewModel?.itemSelected == false {
            self.viewModel?.speechTranscription.value = ""
            if #available(iOS 10.0, *) {
                self.viewModel?.speechController.speechTranscription.value = ""
            }
            textField.text = ""
            self.viewModel?.getHistoryAndFavorites()
        }
        self.updateCollectionView(show: false)
    }
}
