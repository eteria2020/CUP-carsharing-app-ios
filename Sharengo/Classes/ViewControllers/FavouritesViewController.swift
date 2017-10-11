//
//  FavouritesViewController.swift
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
import KeychainSwift

/**
 The Favourites class shows the list of favorites with the ability to handle them
 */
public class FavouritesViewController : BaseViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_headerTitle: UILabel!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    @IBOutlet fileprivate weak var btn_newFavourite: UIButton!
    @IBOutlet fileprivate weak var view_title: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var view_popup: UIView!
    @IBOutlet fileprivate weak var btn_action: UIButton!
    @IBOutlet fileprivate weak var btn_undo: UIButton!
    @IBOutlet fileprivate weak var lbl_popupTitle: UILabel!
    @IBOutlet fileprivate weak var lbl_popupDescription: UILabel!
    @IBOutlet fileprivate weak var txt_address: AnimatedTextInput!
    @IBOutlet fileprivate weak var txt_name: AnimatedTextInput!
    /// ViewModel variable used to represents the data
    public var viewModel: FavouritesViewModel?
    /// Variable used to check if the screen is opened from favourites or not
    public var fromNoFavourites: Bool = false
    /// Variable used to save the selected address
    public var selectedAddress: Address?
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? FavouritesViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .newFavourite:
                let destination: NewFavouriteViewController = (Storyboard.main.scene(.newFavourite))
                destination.bind(to: ViewModelFactory.newFavourite(), afterLoad: true)
                destination.fromFavourites = true
                self.navigationController?.pushViewController(destination, animated: true)
            default: break
            }
        }).addDisposableTo(self.disposeBag)
        self.viewModel = viewModel
        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        self.viewModel?.reload()
        self.btn_newFavourite.rx.bind(to: viewModel.selection, input: .newFavourite)
    }
    
    // MARK: - View methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.noFavouritesBackground.value
        self.view_title.backgroundColor = Color.favouritesTitle.value
        self.btn_newFavourite.style(.squaredButton(Color.loginContinueAsNotLoggedButton.value), title: "btn_noFavouritesNewFavourite".localized())
        self.btn_undo.style(.clearButton(Font.favouritesUndoButton.value, ColorBrand.white.value), title: "btn_favouritesUndo".localized())
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
            self.btn_action.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 33
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
            self.btn_action.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 36
        case 4.7, 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
            self.btn_action.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        //case 5.5:
        default:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
            self.btn_newFavourite.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
            self.btn_action.constraint(withIdentifier: "buttonHeight", searchInSubviews: false)?.constant = 38
        //default:
        //    break
        }
        self.lbl_headerTitle.styledText = "lbl_favouritesHeaderTitle".localized()
        self.lbl_title.styledText = "lbl_favouritesTitle".localized()
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                self?.present(SideMenuManager.default.menuRightNavigationController!, animated: true, completion: nil)
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
        self.btn_back.setImage(self.btn_back.image(for: .normal)?.tinted(UIColor.white), for: .normal)
        self.btn_back.rx.tap.asObservable()
            .subscribe(onNext:{
                if self.fromNoFavourites == true {
                    if let viewControllers = self.navigationController?.viewControllers {
                        if let currentIndex = viewControllers.index(of: self)  {
                            if currentIndex-3 >= 0 {
                                self.navigationController?.popToViewController(viewControllers[currentIndex-3], animated: true)
                            }
                        }
                    }
                } else {
                    Router.back(self)
                }
            }).addDisposableTo(disposeBag)
        self.btn_undo.rx.tap.asObservable()
            .subscribe(onNext:{
                self.view.endEditing(true)
                self.view_popup.isHidden = true
            }).addDisposableTo(disposeBag)
        self.btn_action.rx.tap.asObservable()
            .subscribe(onNext:{
                self.view.endEditing(true)
                if self.lbl_popupTitle.text == "lbl_favouritesDeleteFav".localized() {
                    if var dictionary = UserDefaults.standard.object(forKey: "favouritesAddressDic") as? [String: Data] {
                        if let username = KeychainSwift().get("Username") {
                            if let array = dictionary[username] {
                                if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                                    let index = unarchivedArray.index(where: { (address) -> Bool in
                                        return address.identifier == self.selectedAddress?.identifier
                                    })
                                    if index != nil {
                                        unarchivedArray.remove(at: index!)
                                    }
                                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                                    dictionary[username] = archivedArray
                                    UserDefaults.standard.set(dictionary, forKey: "favouritesAddressDic")
                                }
                            }
                        }
                    }
                } else if self.lbl_popupTitle.text == "lbl_favouritesDeleteHis".localized() {
                    if var dictionary = UserDefaults.standard.object(forKey: "historyDic") as? [String: Data] {
                        if let username = KeychainSwift().get("Username") {
                            if let array = dictionary[username] {
                                if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [HistoryAddress] {
                                    let index = unarchivedArray.index(where: { (address) -> Bool in
                                        return address.identifier == self.selectedAddress?.identifier
                                    })
                                    if index != nil {
                                        unarchivedArray.remove(at: index!)
                                    }
                                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                                    dictionary[username] = archivedArray
                                    UserDefaults.standard.set(dictionary, forKey: "historyDic")
                                }
                            }
                        }
                    }
                } else if self.lbl_popupTitle.text == "lbl_favouritesModify".localized() {
                    if self.txt_address.text?.isEmpty == true || self.txt_name.text?.isEmpty == true  {
                        let message = "alert_newFavouriteMissingFields".localized()
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                        return
                    }
                    if var dictionary = UserDefaults.standard.object(forKey: "favouritesAddressDic") as? [String: Data] {
                        if let username = KeychainSwift().get("Username") {
                            if let array = dictionary[username] {
                                if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                                    let index = unarchivedArray.index(where: { (address) -> Bool in
                                        return address.identifier == self.selectedAddress?.identifier
                                    })
                                    if index != nil {
                                        unarchivedArray[index!].name = self.txt_name.text!
                                        unarchivedArray[index!].address = self.txt_address.text!
                                    }
                                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                                    dictionary[username] = archivedArray
                                    UserDefaults.standard.set(dictionary, forKey: "favouritesAddressDic")
                                }
                            }
                        }
                    }
                } else if self.lbl_popupTitle.text == "lbl_favouritesAdd".localized() {
                    if self.txt_address.text?.isEmpty == true || self.txt_name.text?.isEmpty == true  {
                        let message = "alert_newFavouriteMissingFields".localized()
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
                        return
                    }
                    if var dictionary = UserDefaults.standard.object(forKey: "historyDic") as? [String: Data] {
                        if let username = KeychainSwift().get("Username") {
                            if let array = dictionary[username] {
                                if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [HistoryAddress] {
                                    let index = unarchivedArray.index(where: { (address) -> Bool in
                                        return address.identifier == self.selectedAddress?.identifier
                                    })
                                    if index != nil {
                                        unarchivedArray.remove(at: index!)
                                    }
                                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                                    dictionary[username] = archivedArray
                                    UserDefaults.standard.set(dictionary, forKey: "historyDic")
                                }
                            }
                        }
                    }
                    if var dictionary = UserDefaults.standard.object(forKey: "favouritesAddressDic") as? [String: Data] {
                        if let username = KeychainSwift().get("Username") {
                            if let array = dictionary[username] {
                                if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                                    let uuid = NSUUID().uuidString.lowercased()
                                    let addres = FavouriteAddress(identifier: uuid, name: self.txt_name.text!, location: self.selectedAddress?.location, address: self.txt_address.text!)
                                    unarchivedArray.insert(addres, at: 0)
                                    let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                                    dictionary[username] = archivedArray
                                    UserDefaults.standard.set(dictionary, forKey: "favouritesAddressDic")
                                }
                            }
                        }
                    }
                }
                self.view_popup.isHidden = true
                self.viewModel?.updateData()
                self.viewModel?.reload()
                self.collectionView?.reloadData()
                if var dictionary = UserDefaults.standard.object(forKey: "favouritesAddressDic") as? [String: Data] {
                    if let username = KeychainSwift().get("Username") {
                        if let array = dictionary[username] {
                            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                                if unarchivedArray.count == 0 {
                                    let destination: NoFavouritesViewController = (Storyboard.main.scene(.noFavourites))
                                    destination.bind(to: ViewModelFactory.noFavourites(), afterLoad: true)
                                    var array = self.navigationController?.viewControllers ?? []
                                    array.removeLast()
                                    array.append(destination)
                                    self.navigationController?.viewControllers = array
                                }
                            }
                        }
                    }
                }
            }).addDisposableTo(disposeBag)
        self.view_popup.isHidden = true
        self.txt_address.delegate = self
        self.txt_address.returnKeyType = UIReturnKeyType.done
        self.txt_address.placeHolderText = "txt_newFavouriteAddressPlaceholder".localized()
        self.txt_address.style = CustomTextInputStyle2()
        self.txt_name.delegate = self
        self.txt_name.returnKeyType = UIReturnKeyType.done
        self.txt_name.placeHolderText = "txt_newFavouriteNamePlaceholder".localized()
        self.txt_name.style = CustomTextInputStyle2()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel?.updateData()
        self.viewModel?.reload()
        self.collectionView?.reloadData()
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
        //let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        let width = collectionView.bounds.size.width
        return CGSize(width: width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height+self.view_title.frame.size.height))/5)
    }
    
    /**
     This method is called from collection delegate when an option of the list is selected
     */
    public  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
    
    /**
     This method is called from collection delegate before display a cell to change list interface
     */
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let favCell = cell as? FavouriteItemCollectionViewCell else {
            return
        }
        favCell.btn_action1.rx.tap.asObservable()
            .subscribe(onNext:{
                guard let itemViewModel = favCell.viewModel as? FavouriteItemViewModel else {
                    return
                }
                switch Device().diagonal {
                case 3.5:
                    self.view.constraint(withIdentifier: "viewPopupHeight", searchInSubviews: true)?.constant = 325
                case 4:
                    self.view.constraint(withIdentifier: "viewPopupHeight", searchInSubviews: true)?.constant = 325
                case 4.7, 5.8:
                    self.view.constraint(withIdentifier: "viewPopupHeight", searchInSubviews: true)?.constant = 375
                //case 5.5:
                default:
                    self.view.constraint(withIdentifier: "viewPopupHeight", searchInSubviews: true)?.constant = 375
                //default:
                //    break
                }
                self.btn_action.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_ok".localized())
                self.txt_name.isHidden = false
                self.txt_address.isHidden = false
                self.lbl_popupDescription.isHidden = true
                if itemViewModel.favourite {
                    self.lbl_popupTitle.styledText = "lbl_favouritesModify".localized()
                    self.txt_address.text = (itemViewModel.model as? Address)?.address
                    self.txt_name.text = (itemViewModel.model as? Address)?.name
                } else {
                    self.lbl_popupTitle.styledText = "lbl_favouritesAdd".localized()
                    self.txt_address.text = (itemViewModel.model as? Address)?.name
                    self.txt_name.text = nil
                }
                self.selectedAddress = itemViewModel.model as? Address
                self.view_popup.isHidden = false
            }).addDisposableTo(disposeBag)
        favCell.btn_action2.rx.tap.asObservable()
            .subscribe(onNext:{
                guard let itemViewModel = favCell.viewModel as? FavouriteItemViewModel else {
                    return
                }
                switch Device().diagonal {
                case 3.5:
                    self.view.constraint(withIdentifier: "viewPopupHeight", searchInSubviews: true)?.constant = 250
                case 4:
                    self.view.constraint(withIdentifier: "viewPopupHeight", searchInSubviews: true)?.constant = 250
                case 4.7, 5.8:
                    self.view.constraint(withIdentifier: "viewPopupHeight", searchInSubviews: true)?.constant = 275
                //case 5.5:
                default:
                    self.view.constraint(withIdentifier: "viewPopupHeight", searchInSubviews: true)?.constant = 300
                //default:
                //    break
                }
                self.txt_name.isHidden = true
                self.txt_address.isHidden = true
                self.lbl_popupDescription.styledText = itemViewModel.title
                self.lbl_popupDescription.isHidden = false
                self.btn_action.style(.roundedButton(Color.alertButtonsPositiveBackground.value), title: "btn_favouritesDelete".localized())
                if itemViewModel.favourite {
                    self.lbl_popupTitle.styledText = "lbl_favouritesDeleteFav".localized()
                } else {
                    self.lbl_popupTitle.styledText = "lbl_favouritesDeleteHis".localized()
                }
                self.selectedAddress = itemViewModel.model as? Address
                self.view_popup.isHidden = false
            }).addDisposableTo(disposeBag)
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = Color.settingEvenCellBackground.value
        } else {
            cell.backgroundColor = Color.settingOddCellBackground.value
        }
    }
}

extension FavouritesViewController: AnimatedTextInputDelegate
{
    // MARK: - TextField delegate
    
    /**
     This method is called when user try to close keyboard
     */
    public func animatedTextInputShouldReturn(animatedTextInput: AnimatedTextInput) -> Bool {
        _ = animatedTextInput.resignFirstResponder()
        
        return true
    }
}

