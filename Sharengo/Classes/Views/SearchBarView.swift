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
import DeviceKit

/**
 The SearchBarView class is a view where user can input text to search
 */
class SearchBarView : UIView, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_black: UIView!
    @IBOutlet fileprivate weak var view_background: UIView!
    @IBOutlet fileprivate weak var icn_search: UIImageView!
    @IBOutlet fileprivate weak var view_microphone: UIView!
    @IBOutlet fileprivate weak var btn_microphone: UIButton!
    @IBOutlet fileprivate weak var view_search: UIView!
    @IBOutlet fileprivate weak var txt_search: UITextField!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    /// ViewModel variable used to represents the data
    public var viewModel: SearchBarViewModel?
    /// Main view of the search bar
    public var view: UIView!
    /// Variable used to check if search bar is showed in favourites screen or not
    public var favourites: Bool = false
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
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
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    fileprivate func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        self.layoutIfNeeded()
        self.view_black.alpha = 0.0
        self.collectionView.isHidden = true
        self.collectionView.backgroundColor = Color.searchBarResultBackground.value
        self.view_background.backgroundColor = Color.searchBarBackground.value
        self.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
        self.btn_microphone.layer.cornerRadius = self.btn_microphone.frame.size.width/2
        self.btn_microphone.layer.masksToBounds = true
        self.txt_search.attributedPlaceholder = NSAttributedString(string:"lbl_searchBarTextField".localized(), attributes:[NSForegroundColorAttributeName: Color.searchBarTextFieldPlaceholder.value, NSFontAttributeName: Font.searchBarTextFieldPlaceholder.value])
        guard let viewModel = viewModel else {
            return
        }
        viewModel.speechInProgress.asObservable()
            .subscribe(onNext: {[weak self] (speechInProgress) in
                DispatchQueue.main.async {[weak self]  in
                    if speechInProgress {
                        self?.txt_search.becomeFirstResponder()
                        self?.updateCollectionView(show: true)
                        self?.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophoneSpeechInProgress.value
                    } else {
                        self?.btn_microphone.backgroundColor = Color.searchBarBackgroundMicrophone.value
                    }
                }
            }).addDisposableTo(disposeBag)
        viewModel.speechTranscription.asObservable()
            .subscribe(onNext: {[weak self] (speechTransition) in
                DispatchQueue.main.async {[weak self]  in
                    if self?.viewModel?.speechInProgress.value == true {
                        self?.txt_search.text = speechTransition ?? ""
                        if speechTransition != nil && self?.viewModel?.speechInProgress.value == true {
                            self?.viewModel?.stopRequest()
                            self?.viewModel?.reloadResults(text: speechTransition ?? "")
                        }
                    }
                }
            }).addDisposableTo(self.disposeBag)
        viewModel.hideButton.asObservable()
            .subscribe(onNext: {[weak self] (hideButton) in
                DispatchQueue.main.async {[weak self]  in
                    if hideButton {
                        self?.view_microphone.alpha = 0.5
                    } else {
                        self?.view_microphone.alpha = 1.0
                    }
                }
            }).addDisposableTo(self.disposeBag)
        self.btn_microphone.rx.bind(to: viewModel.selection, input: .dictated)
        switch Device().diagonal {
        case 3.5:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 119
        case 4:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 179
        case 4.7, 5.8:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 259
        //case 5.5:
        default:
            self.collectionView.constraint(withIdentifier: "searchBarHeight", searchInSubviews: false)?.constant = 299
        //default:
        //    break
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
    
    // MARK: - Interface methods
    
    /**
     This method is called by the system when user executes a touch on the screen
     */
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.view_background.point(inside: convert(point, to: self.view_background), with: event) {
            return true
        }
        if self.collectionView.point(inside: convert(point, to: self.collectionView), with: event) && txt_search.isFirstResponder {
            return true
        }
        return false
    }
    
    /**
     This method updates interface
     */
    public func updateInterface() {
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
    
    /**
     This method updates collectionView's interface
     */
    public func updateCollectionView(show: Bool) {
        if show {
            DispatchQueue.main.async {[weak self]  in
                self?.collectionView.isHidden = false
                self?.viewModel?.reload()
                self?.collectionView?.reloadData()
                self?.collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 10, height: 10), animated: false)
            }
        } else {
            DispatchQueue.main.async {[weak self]  in
                self?.view_black.alpha = 0.0
                self?.collectionView.isHidden = true
                self?.endEditing(true)
                self?.viewModel?.reload()
                self?.collectionView?.reloadData()
                if (self?.favourites ?? false) {
                    self?.view_background.alpha = 0.0
                }
            }
        }
    }
    
    /**
     This method closes keyboard
     */
    public func stopSearchBar() {
        self.endEditing(true)
    }
    
    /**
     This method setup interface for favourites screen
     */
    public func setupForFavourites() {
        self.favourites = true
        self.viewModel?.favourites = true
        self.view_background.alpha = 0.0
    }
    
    /**
     This method shows search bar with animation
     */
    public func showSearchBar() {
        self.viewModel?.reloadResults(text: self.txt_search.text ?? "")
        switch Device().diagonal {
        case 3.5:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 70
        case 4:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 93
        case 4.7, 5.8:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 98
        //case 5.5:
        default:
            self.view.constraint(withIdentifier: "topBackgroundView", searchInSubviews: true)?.constant = 105
        //default:
        //    break
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view_background.alpha = 1.0
            self.view_black.alpha = 0.65
        }) { (success) in
            self.txt_search.becomeFirstResponder()
        }
    }
    
    // MARK: - Data methods
    
    /**
     This method stops search request
     */
    public func stopRequest() {
        self.viewModel?.stopRequest()
    }
    
    /**
     This method starts search request
     - Parameter text: text to find
     */
    public func getResults(text: String) {
        self.stopRequest()
        self.viewModel?.reloadResults(text: text)
    }
    
    // MARK: - Collection methods
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (line spacing)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (interitem spacing)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (inset)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    /**
     This method is called from collection delegate to decide how the list interface is showed (size)
     */
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width
        var height: CGFloat = 0.0
        switch Device().diagonal {
        case 3.5:
            height = 60.0
        case 4:
            height = 60.0
        case 4.7, 5.8:
            height = 65.0
        //case 5.5:
        default:
            height = 75.0
        //default:
        //    break
        }
        let newSize = CGSize(width: width, height: height)
        return newSize
    }
    
    /**
     This method is called from collection delegate when an option of the list is selected
     */
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
}

extension SearchBarView: UITextFieldDelegate {
    // MARK: - UITextField delegate
    
    /**
     This method updates collection view when user tap on textField
     */
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.updateCollectionView(show: true)
    }
    
    /**
     This method calls get results while user enter text to find
     */
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        return true
    }
    
    /**
     This method is called from textfield when keyboard is closed
     */
    public func textFieldDidEndEditing(_ textField: UITextField) {
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
