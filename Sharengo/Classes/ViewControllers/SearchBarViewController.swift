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
    }
    
    // MARK: - TextField methods
    
    func startSearching() {
        print("Start Searching")
    }
    
    // MARK: - Microphone methods
    
    func startDictated() {
        print("Start Dictated")
    }
}
