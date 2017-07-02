//
//  NewFavouriteViewController.swift
//  Sharengo
//
//  Created by Dedecube on 28/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SideMenu
import DeviceKit
import TPKeyboardAvoiding

class NewFavouriteViewController : BaseViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var img_top: UIImageView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var lbl_description: UILabel!
    @IBOutlet fileprivate weak var txt_address: AnimatedTextInput!
    @IBOutlet fileprivate weak var txt_name: AnimatedTextInput!
    @IBOutlet fileprivate weak var btn_saveFavourite: UIButton!
    @IBOutlet fileprivate weak var btn_undo: UIButton!
    @IBOutlet fileprivate weak var btn_address: UIButton!
    @IBOutlet fileprivate weak var scrollView_main: TPKeyboardAvoidingScrollView!
    @IBOutlet fileprivate weak var view_scrollViewContainer: UIView!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    @IBOutlet fileprivate weak var view_searchBar: SearchBarView!
    
    var viewModel: NewFavouriteViewModel?
    var fromFavourites: Bool = false
    fileprivate var selectedAddress: Address?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? NewFavouriteViewModel else {
            return
        }
        self.viewModel = viewModel
        
        self.btn_saveFavourite.rx.tap.asObservable()
            .subscribe(onNext:{
                self.view_searchBar.endEditing(true)
                self.view.endEditing(true)
                if self.selectedAddress == nil || self.txt_name.text?.isEmpty == true  {
                    let message = "alert_newFavouriteMissingFields".localized()
                    let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                        alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
                    return
                }
                if let array = UserDefaults.standard.object(forKey: "favouritesArray") as? Data {
                    if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                        let uuid = NSUUID().uuidString.lowercased()
                        let addres = FavouriteAddress(identifier: uuid, name: self.txt_name.text!, location: self.selectedAddress?.location, address: self.selectedAddress?.name)
                        unarchivedArray.insert(addres, at: 0)
                        let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                        UserDefaults.standard.set(archivedArray, forKey: "favouritesArray")
                    }
                }
                if self.fromFavourites {
                    Router.back(self)
                } else {
                    let destination: FavouritesViewController = (Storyboard.main.scene(.favourites))
                    destination.bind(to: ViewModelFactory.favourites(), afterLoad: true)
                    self.navigationController?.pushViewController(destination, animated: true)
                }
            }).addDisposableTo(disposeBag)
        self.btn_address.rx.tap.asObservable()
            .subscribe(onNext:{
                self.view_searchBar.endEditing(true)
                self.view_searchBar.showSearchBar()
                self.view.endEditing(true)
        }).addDisposableTo(disposeBag)
        self.btn_undo.rx.tap.asObservable()
            .subscribe(onNext:{
                self.view_searchBar.endEditing(true)
                self.view.endEditing(true)
                Router.back(self)
        }).addDisposableTo(disposeBag)
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.noFavouritesBackground.value
        
        self.btn_saveFavourite.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_newFavouriteSaveFavourite".localized())
        self.btn_undo.style(.clearButton(Font.favouritesUndoButton.value, Color.alertButton.value), title: "btn_newFavouriteUndo".localized())
        
        self.lbl_headerTitle.styledText = "lbl_newFavouriteHeaderTitle".localized()
        self.lbl_title.styledText = "lbl_newFavouriteTitle".localized()
        self.lbl_description.styledText = "lbl_newFavouriteDescription".localized()
        
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.img_top.constraint(withIdentifier: "imageHeight", searchInSubviews: false)?.constant = 130
            self.btn_saveFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
            self.view.constraint(withIdentifier: "topTxtName", searchInSubviews: true)?.constant = 0
            self.view.constraint(withIdentifier: "topTxtAddress", searchInSubviews: true)?.constant = 5
            self.view.constraint(withIdentifier: "bottomButtonUndo", searchInSubviews: true)?.constant = 5
            self.view.constraint(withIdentifier: "bottomButtonSave", searchInSubviews: true)?.constant = 5
            self.view.constraint(withIdentifier: "topTxtTitle", searchInSubviews: true)?.constant = 15
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_saveFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
            self.view.constraint(withIdentifier: "topTxtName", searchInSubviews: true)?.constant = 5
            self.view.constraint(withIdentifier: "topTxtAddress", searchInSubviews: true)?.constant = 5
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_saveFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_saveFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        default:
            break
        }
        
        self.txt_address.placeHolderText = "txt_newFavouriteAddressPlaceholder".localized()
        self.txt_address.style = CustomTextInputStyle1()
        
        self.txt_name.delegate = self
        self.txt_name.returnKeyType = UIReturnKeyType.done
        self.txt_name.placeHolderText = "txt_newFavouriteNamePlaceholder".localized()
        self.txt_name.style = CustomTextInputStyle1()
      
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                self?.present(SideMenuManager.menuRightNavigationController!, animated: true, completion: nil)
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
        // SearchBar
        self.view_searchBar.bind(to: ViewModelFactory.searchBar())
        self.view_searchBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .reload:
                self?.view_searchBar.updateCollectionView(show: true)
            case .address(let address):
                self?.selectedAddress = address
                self?.txt_address.text = address.name
                self?.view_searchBar.updateCollectionView(show: false)
                if self?.view_searchBar.viewModel?.speechInProgress.value == true {
                    self?.view_searchBar.viewModel?.speechInProgress.value = false
                    if #available(iOS 10.0, *) {
                        self?.view_searchBar.viewModel?.speechController.manageRecording()
                    }
                }
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        self.view_searchBar.setupForFavourites()
        
        self.btn_back.setImage(self.btn_back.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_back.rx.tap.asObservable()
            .subscribe(onNext:{
                self.view.endEditing(true)
                self.view_searchBar.endEditing(true)
                Router.back(self)
        }).addDisposableTo(disposeBag)
        
        NotificationCenter.default.addObserver(forName:
        NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) {
            [unowned self] notification in
            self.view_searchBar.updateInterface()
        }
    }
    
    deinit {
        // TODO: rimuovere
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - TextField delegate

extension NewFavouriteViewController: AnimatedTextInputDelegate
{
    func animatedTextInputShouldReturn(animatedTextInput: AnimatedTextInput) -> Bool
    {
        _ = animatedTextInput.resignFirstResponder()
        
        return true
    }
}
