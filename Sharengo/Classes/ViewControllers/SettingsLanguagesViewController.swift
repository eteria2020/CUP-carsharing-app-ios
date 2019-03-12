//
//  SettingsLanguagesViewController.swift
//  Sharengo
//
//  Created by Dedecube on 27/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import SideMenu
import DeviceKit
import Localize_Swift
import KeychainSwift

/**
 The Settings language class lets user select his favorite language
 */
public class SettingsLanguagesViewController : BaseViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_title: UILabel!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var btn_back: UIButton!
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    /// ViewModel variable used to represents the data
    public var viewModel: SettingsLanguagesViewModel?
    
    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SettingsLanguagesViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext:{ selection in
            switch selection {
            case .italian:
                if var dictionary = UserDefaults.standard.object(forKey: "languageDic") as? [String: String] {
                    if let username = KeychainSwift().get("Username") {
                        dictionary[username] = "it"
                        UserDefaults.standard.set(dictionary, forKey: "languageDic")
                    }
                }
                Localize.setCurrentLanguage("it")
                self.updateLanguages()
            case .english:
                if var dictionary = UserDefaults.standard.object(forKey: "languageDic") as? [String: String] {
                    if let username = KeychainSwift().get("Username") {
                        dictionary[username] = "en"
                        UserDefaults.standard.set(dictionary, forKey: "languageDic")
                    }
                }
                Localize.setCurrentLanguage("en")
                self.updateLanguages()
            default: break
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        self.viewModel = viewModel
        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        self.lbl_title.styledText = self.viewModel?.title
        
        self.viewModel?.reload()
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // self.view.layoutIfNeeded()
        self.view_header.backgroundColor = Color.settingHeaderBackground.value
        self.lbl_title.textColor = Color.settingHeaderLabel.value
        
        switch Device().diagonal {
        case 3.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 30
        case 4.7:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.5:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 32
        case 5.8:
            self.view_header.constraint(withIdentifier: "viewHeaderHeight", searchInSubviews: true)?.constant = 34
        default:
            break
        }
        // NavigationBar
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
                Router.back(self)
        }).addDisposableTo(disposeBag)
    }
    
    // MARK: - Update methods
    
    /**
     This method is used to update language interface after user selection
    */
    public func updateLanguages() {
        DispatchQueue.main.async {
            self.viewModel?.updateData()
            self.viewModel?.reload()
            self.collectionView?.reloadData()
            self.lbl_title.styledText = self.viewModel?.title
        }
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
        let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        return CGSize(width: size.width, height: (UIScreen.main.bounds.height-(56+self.view_header.frame.size.height))/4)
    }
    
    /**
     This method is called from collection delegate when an option of the list is selected
     */
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
    
    /**
     This method is called from collection delegate before display a cell to change list interface
     */
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = Color.settingsLanguagesEvenCellBackground.value
        } else {
            cell.backgroundColor = Color.settingsLanguagesOddCellBackground.value
        }
    }
}
