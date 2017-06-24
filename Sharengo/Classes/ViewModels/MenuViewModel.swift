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
    case profileEco
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
                print(self.model(atIndex: indexPath))
                guard let model = self.model(atIndex: indexPath) as? MenuItemViewModel else { return .empty() }
                print(model.title)
                return .just(.empty)
            case .profileEco:
                return .just(.viewModel(ViewModelFactory.profile()))
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
            let menuItem4 = MenuItem(title: "lbl_menuRates", icon: "ic_tariffe")
            let menuItem5 = MenuItem(title: "lbl_menuHelp", icon: "ic_assistenza")
            menuItems.append(menuItem1)
            menuItems.append(menuItem2)
            menuItems.append(menuItem3)
            menuItems.append(menuItem4)
            menuItems.append(menuItem5)
            return menuItems
        } else {
            welcome = String(format: "lbl_menuHeaderTitleLogged".localized(), KeychainSwift().get("UserFirstname")!)
            var menuItems = [MenuItem]()
            let menuItem1 = MenuItem(title: "lbl_menuProfile", icon: "ic_profilo")
            let menuItem2 = MenuItem(title: "lbl_menuSearchCars", icon: "ic_prenota")
            let menuItem3 = MenuItem(title: "lbl_menuRaces", icon: "ic_cron_corse")
            let menuItem4 = MenuItem(title: "lbl_menuHelp", icon: "ic_assistenza")
            let menuItem5 = MenuItem(title: "lbl_menuFaq", icon: "ic_faq_nero")
            let menuItem6 = MenuItem(title: "lbl_menuBuyMinutes", icon: "ic_acquistaminuti")
            let menuItem7 = MenuItem(title: "lbl_menuInvite", icon: "ic_invita_amico")
            let menuItem8 = MenuItem(title: "lbl_menuSettings", icon: "ic_impostazioni")
            let menuItem9 = MenuItem(title: "lbl_menuLogout", icon: "ic_logout")
            menuItems.append(menuItem1)
            menuItems.append(menuItem2)
            menuItems.append(menuItem3)
            menuItems.append(menuItem4)
            menuItems.append(menuItem5)
            menuItems.append(menuItem6)
            menuItems.append(menuItem7)
            menuItems.append(menuItem8)
            menuItems.append(menuItem9)
            return menuItems
        }
    }
}
