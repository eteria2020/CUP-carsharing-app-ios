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

/**
 Enum that specifies selection input
 */
public enum MenuSelectionInput : SelectionInput {
    case item(IndexPath)
    case profileEco
}

/**
 Enum that specifies selection output
 */
public enum MenuSelectionOutput : SelectionOutput {
    case viewModel(ViewModelType)
    case logout
    case empty
}

/**
 The Menu model provides data related to display content on the menu
 */
public final class MenuViewModel : ListViewModelType, ViewModelTypeSelectable {
    fileprivate var resultsDispose: DisposeBag?
    /// ViewModel variable used to save data
    public var dataHolder: ListDataHolderType = ListDataHolder.empty
    /// Variable used to save header message
    public var welcome = ""
    /// Variable used to save is user icon has to be shown or not
    public var userIconIsHidden = true
    /// Selection variable
    public lazy var selection:Action<MenuSelectionInput,MenuSelectionOutput> = Action { input in
        return .empty()
    }
    
    // MARK: - ViewModel methods
    
    public func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? MenuItem {
            return ViewModelFactory.menuItem(fromModel: item)
        }
        return nil
    }
    
    // MARK: - Init methods
    
    public init() {
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
                    case is MapViewModel:
                        if !(CoreController.shared.currentViewController is MapViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is SettingsViewModel:
                        if !(CoreController.shared.currentViewController is SettingsViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is CarTripsViewModel:
                        if !(CoreController.shared.currentViewController is CarTripsViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is InviteFriendViewModel:
                        if !(CoreController.shared.currentViewController is InviteFriendViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is FaqViewModel:
                        if !(CoreController.shared.currentViewController is FaqViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is UserAreaViewModel:
                        if !(CoreController.shared.currentViewController is UserAreaViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is SupportViewModel:
                        if !(CoreController.shared.currentViewController is SupportViewController) {
                            return .just(.viewModel(viewModel))
                        }
                    case is RatesViewModel:
                        if !(CoreController.shared.currentViewController is RatesViewController) {
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
    
    /**
     This method updates menu options if the user logs in or not
     */
    public func updateData() {
        var menuItems = [MenuItem]()
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            self.welcome = "lbl_menuHeaderTitleGuest".localized()
            self.userIconIsHidden = true
            let menuItem1 = MenuItem(title: "lbl_menuLogin", icon: "ic_login", viewModel: ViewModelFactory.login())
            let menuItem2 = MenuItem(title: "lbl_menuSignUp", icon: "ic_iscrizione", viewModel: ViewModelFactory.signup())
            let menuItem3 = MenuItem(title: "lbl_menuFaq", icon: "ic_faq_nero", viewModel: ViewModelFactory.faq())
            let menuItem4 = MenuItem(title: "lbl_menuRates", icon: "ic_tariffe", viewModel: ViewModelFactory.rates())
            let menuItem5 = MenuItem(title: "lbl_menuHelp", icon: "ic_assistenza", viewModel: ViewModelFactory.support())
            menuItems.append(menuItem1)
            menuItems.append(menuItem2)
            menuItems.append(menuItem3)
            menuItems.append(menuItem4)
            menuItems.append(menuItem5)
        } else {
            if KeychainSwift().get("UserFirstname") != nil {
                if KeychainSwift().get("UserGender") == "female" {
                    self.welcome = String(format: "lbl_menuHeaderTitleLoggedF".localized(), KeychainSwift().get("UserFirstname")!)
                }
                else {
                    self.welcome = String(format: "lbl_menuHeaderTitleLogged".localized(), KeychainSwift().get("UserFirstname")!)
                }
            }
            else {
                self.welcome = String(format: "lbl_menuHeaderTitleLoggedWithoutFirstName".localized())
            }
            self.userIconIsHidden = false
            let menuItem1 = MenuItem(title: "lbl_menuProfile", icon: "ic_profilo", viewModel: ViewModelFactory.userArea())
            let menuItem2 = MenuItem(title: "lbl_menuSearchCars", icon: "ic_prenota", viewModel: ViewModelFactory.map(type: .searchCars))
            let menuItem3 = MenuItem(title: "lbl_menuRaces", icon: "ic_cron_corse", viewModel: ViewModelFactory.carTrips())
            let menuItem4 = MenuItem(title: "lbl_menuHelp", icon: "ic_assistenza", viewModel: ViewModelFactory.support())
            let menuItem5 = MenuItem(title: "lbl_menuFaq", icon: "ic_faq_nero", viewModel: ViewModelFactory.faq())
            let menuItem6 = MenuItem(title: "lbl_menuSettings", icon: "ic_impostazioni", viewModel: ViewModelFactory.settings())
            let menuItem7 = MenuItem(title: "lbl_menuLogout", icon: "ic_logout", viewModel: ViewModelFactory.home())
            let menuItem8 = MenuItem(title: "lbl_menuRates", icon: "ic_tariffe", viewModel: ViewModelFactory.rates())
            menuItems.append(menuItem1)
            menuItems.append(menuItem2)
            menuItems.append(menuItem3)
            menuItems.append(menuItem8)
            menuItems.append(menuItem4)
            menuItems.append(menuItem5)
            menuItems.append(menuItem6)
            menuItems.append(menuItem7)
        }
        self.dataHolder = ListDataHolder(data:Observable.just(menuItems).structured())
    }
}
