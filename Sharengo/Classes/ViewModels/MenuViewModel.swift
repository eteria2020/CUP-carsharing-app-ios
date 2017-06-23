//
//  MenuViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import KeychainSwift

enum MenuSelectionInput : SelectionInput {
    case item(IndexPath)
}
enum MenuSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

final class MenuViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var welcome = ""
    fileprivate var resultsDispose: DisposeBag?
    
    lazy var selection:Action<MenuSelectionInput,MenuSelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? MenuItem {
            return ViewModelFactory.menuItem(fromModel: item)
        }
        return nil
    }
    
    init() {
        self.dataHolder = ListDataHolder(data:Observable.just(updateData()).structured())

        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                return .just(.empty)
            }
        }
    }
    
    func updateData() -> [MenuItem]
    {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            welcome = "lbl_menuHeaderTitleGuest".localized()

            var menuItems = [MenuItem]()
            let menuItem1 = MenuItem(title: "lbl_menuLogin", icon: "ic_login")
            let menuItem2 = MenuItem(title: "lbl_menuSignUp", icon: "ic_iscrizione")
            let menuItem3 = MenuItem(title: "lbl_menuFaq", icon: "ic_faq_nero")
            let menuItem4 = MenuItem(title: "lbl_rates", icon: "ic_tariffe")
            let menuItem5 = MenuItem(title: "lbl_help", icon: "ic_assistenza")
            menuItems.append(menuItem1)
            menuItems.append(menuItem2)
            menuItems.append(menuItem3)
            menuItems.append(menuItem4)
            menuItems.append(menuItem5)
            
            return menuItems
        } else {
            welcome = String(format: "banner_carBookingCompletedDescription".localized(), KeychainSwift().get("Username")!)

            var menuItems = [MenuItem]()
            let menuItem1 = MenuItem(title: "aaa", icon: "ic_close")
            let menuItem2 = MenuItem(title: "aaa", icon: "ic_close")
            menuItems.append(menuItem1)
            menuItems.append(menuItem2)
        
            return menuItems
        }
    }
}
