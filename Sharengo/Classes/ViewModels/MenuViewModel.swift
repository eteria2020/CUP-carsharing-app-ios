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
    case logout
    case empty
}

final class MenuViewModel : ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var welcome = ""
    var userIconIsHidden = true
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
        self.updateData()
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                guard let model = self.model(atIndex: indexPath) as?  MenuItem else { return .empty() }
                if let viewModel = model.viewModel  {
                    switch viewModel {
                    case is HomeViewModel:
                        return .just(.logout)
                    case is LoginViewModel:
                        if !(CoreController.shared.currentViewController is LoginViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is SignupViewModel:
                        if !(CoreController.shared.currentViewController is SignupViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is SearchCarsViewModel:
                        if !(CoreController.shared.currentViewController is SearchCarsViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    default:
                        return .just(.viewModel(viewModel))
                    }
                }
            case .profileEco:
                if !(CoreController.shared.currentViewController is ProfileViewController) {
                    return .just(.viewModel(ViewModelFactory.profile()))
                }
            }
            return .just(.empty)
        }
    }
    
    func updateData() {
        var menuItems = [MenuItem]()
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.welcome = "lbl_menuHeaderTitleGuest".localized()
            self.userIconIsHidden = true
            let menuItem1 = MenuItem(title: "lbl_menuLogin", icon: "ic_login", viewModel: ViewModelFactory.login())
            let menuItem2 = MenuItem(title: "lbl_menuSignUp", icon: "ic_iscrizione", viewModel: ViewModelFactory.signup())
            let menuItem3 = MenuItem(title: "lbl_menuFaq", icon: "ic_faq_nero", viewModel: nil)
            let menuItem4 = MenuItem(title: "lbl_menuRates", icon: "ic_tariffe", viewModel: nil)
            let menuItem5 = MenuItem(title: "lbl_menuHelp", icon: "ic_assistenza", viewModel: nil)
            menuItems.append(menuItem1)
            menuItems.append(menuItem2)
            menuItems.append(menuItem3)
            menuItems.append(menuItem4)
            menuItems.append(menuItem5)
        } else {
            self.welcome = String(format: "lbl_menuHeaderTitleLogged".localized(), KeychainSwift().get("UserFirstname")!)
            self.userIconIsHidden = false
            let menuItem1 = MenuItem(title: "lbl_menuProfile", icon: "ic_profilo", viewModel: nil)
            let menuItem2 = MenuItem(title: "lbl_menuSearchCars", icon: "ic_prenota", viewModel: ViewModelFactory.searchCars())
            let menuItem3 = MenuItem(title: "lbl_menuRaces", icon: "ic_cron_corse", viewModel: nil)
            let menuItem4 = MenuItem(title: "lbl_menuHelp", icon: "ic_assistenza", viewModel: nil)
            let menuItem5 = MenuItem(title: "lbl_menuFaq", icon: "ic_faq_nero", viewModel: nil)
            let menuItem6 = MenuItem(title: "lbl_menuBuyMinutes", icon: "ic_acquistaminuti", viewModel: nil)
            let menuItem7 = MenuItem(title: "lbl_menuInvite", icon: "ic_invita_amico", viewModel: nil)
            let menuItem8 = MenuItem(title: "lbl_menuSettings", icon: "ic_impostazioni", viewModel: nil)
            let menuItem9 = MenuItem(title: "lbl_menuLogout", icon: "ic_logout", viewModel: ViewModelFactory.home())
            menuItems.append(menuItem1)
            menuItems.append(menuItem2)
            menuItems.append(menuItem3)
            menuItems.append(menuItem4)
            menuItems.append(menuItem5)
            menuItems.append(menuItem6)
            menuItems.append(menuItem7)
            menuItems.append(menuItem8)
            menuItems.append(menuItem9)
        }
        self.dataHolder = ListDataHolder(data:Observable.just(menuItems).structured())
    }
}
