//
//  SearchBarViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 18/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action
import ReachabilitySwift
import CoreLocation

enum SearchBarSelectionInput: SelectionInput {
    case item(IndexPath)
    case dictated
    case reload
}
enum SearchBarSelectionOutput: SelectionOutput {
    case empty
    case dictated
    case reload
    case address(Address)
    case car(Car)
}

final class SearchBarViewModel: ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder.empty
    var speechInProgress: Variable<Bool> = Variable(false)
    var speechTranscription: Variable<String?> = Variable(nil)
    var hideButton: Variable<Bool> = Variable(false)
    var itemSelected: Bool = false
    @available(iOS 10.0, *)
    lazy var speechController = SpeechController()
    
    fileprivate var resultsDispose: DisposeBag?
    fileprivate var apiController: ApiController = ApiController()
    fileprivate var nominatimApiController: NominatimAPIController = NominatimAPIController()
    fileprivate let numberOfResults: Int = 15
    var allCars: [Car] = []
    var favourites: Bool = false
    
    lazy var selection:Action<SearchBarSelectionInput,SearchBarSelectionOutput> = Action { input in
        return .empty()
    }
    
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        if let item = model as? Address {
            return ViewModelFactory.searchBarItem(fromModel: item)
        }
        if let item = model as? Car {
            return ViewModelFactory.searchBarItem(fromModel: item)
        }
        if let item = model as? Favorite {
            return ViewModelFactory.searchBarItem(fromModel: item)
        }
        return nil
    }
    
    init() {
        self.selection = Action { input in
            switch input {
            case .item(let indexPath):
                if let model = self.model(atIndex: indexPath) as? Address {
                    self.itemSelected = true
                    var favourite: Bool = false
                    if let array = UserDefaults.standard.object(forKey: "favouritesArray") as? Data {
                        if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                            let index = unarchivedArray.index(where: { (address) -> Bool in
                                return address.identifier == model.identifier
                            })
                            if index != nil {
                               favourite = true
                            }
                        }
                    }
                    if !favourite && !self.favourites {
                        if let array = UserDefaults.standard.object(forKey: "historyArray") as? Data {
                            if var unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [HistoryAddress] {
                                let historyAddress = model.getHistoryAddress()
                                let index = unarchivedArray.index(where: { (address) -> Bool in
                                    return address.identifier == model.identifier
                                })
                                if index != nil {
                                    unarchivedArray.remove(at: index!)
                                }
                                unarchivedArray.insert(historyAddress, at: 0)
                                let archivedArray = NSKeyedArchiver.archivedData(withRootObject: unarchivedArray as Array)
                                UserDefaults.standard.set(archivedArray, forKey: "historyArray")
                            }
                        }
                    }
                    self.speechTranscription.value = model.name
                    return .just(.address(model))
                } else if let model = self.model(atIndex: indexPath) as? Car {
                    self.itemSelected = true
                    self.speechTranscription.value = model.plate
                    return .just(.car(model))
                } else if let model = self.model(atIndex: indexPath) as? Favorite {
                    print(model)
                }
            case .reload:
                return .just(.reload)
            case .dictated:
                if #available(iOS 10.0, *) {
                    if self.speechInProgress.value {
                        self.speechInProgress.value = false
                        self.speechController.manageRecording()
                    } else {
                        self.speechController.speechTranscription.value = self.speechTranscription.value
                        self.speechInProgress.value = true
                        self.speechController.requestSpeechAuthorization()
                        self.speechController.speechInProgress.asObservable()
                            .subscribe(onNext: {[weak self] (speechInProgress) in
                                DispatchQueue.main.async {
                                    self?.speechInProgress.value = speechInProgress
                                }
                            }).addDisposableTo(self.disposeBag)
                        self.speechController.speechTranscription.asObservable()
                            .subscribe(onNext: {[weak self] (speechTransition) in
                                DispatchQueue.main.async {
                                    self?.itemSelected = false
                                    self?.speechTranscription.value = speechTransition ?? ""
                                }
                            }).addDisposableTo(self.disposeBag)
                        self.speechController.speechError.asObservable()
                            .subscribe(onNext: {[weak self] (error) in
                                DispatchQueue.main.async {
                                    self?.itemSelected = false
                                    if let error = error {
                                        self?.speechInProgress.value = false
                                        if error.hideButton() {
                                            self?.hideButton.value = true
                                        }
                                        if error != .empty {
                                            if error.showSettings() == false {
                                                let dialog = ZAlertView(title: nil, message: error.getMessage(), closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                                    alertView.dismissAlertView()
                                                })
                                                dialog.allowTouchOutsideToDismiss = false
                                                dialog.show()
                                            } else {
                                                let dialog = ZAlertView(title: nil, message: error.getMessage(), isOkButtonLeft: false, okButtonText: "btn_ok".localized(), cancelButtonText: "btn_cancel".localized(),
                                                                        okButtonHandler: { alertView in
                                                                            alertView.dismissAlertView()
                                                                            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                                                },
                                                                        cancelButtonHandler: { alertView in
                                                                            alertView.dismissAlertView()
                                                })
                                                dialog.allowTouchOutsideToDismiss = false
                                                dialog.show()
                                            }
                                        }
                                    }
                                }
                            }).addDisposableTo(self.disposeBag)
                    }
                }
                return .just(.dictated)
            }
            return .just(.empty)
        }
        self.getHistoryAndFavorites()
    }
    
    // MARK: - Dictated methods
    
    func dictatedIsAuthorized() -> Bool {
        if #available(iOS 10.0, *) {
            return self.speechController.isAuthorized
        } else {
            return false
        }
    }
    
    // MARK: - Address methods
    
    func stopRequest() {
        self.resultsDispose = nil
        self.resultsDispose = DisposeBag()
    }
    
    func reloadResults(text: String) {
        if text.characters.count > 2 {
            let regex = try? NSRegularExpression(pattern: "^[a-zA-Z]{2}[0-9]")
            let match = regex?.firstMatch(in: text, options: .reportCompletion, range: NSRange(location: 0, length: text.characters.count))
            if match != nil && !favourites {
                self.dataHolder = ListDataHolder(data:Observable.just(self.allCars.filter({ (car) -> Bool in
                    return car.plate?.lowercased().contains(text.lowercased()) ?? false
                })).structured())
                self.selection.execute(.reload)
            } else {
            self.nominatimApiController.searchAddress(text: text)
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe { event in
                    switch event {
                    case .next(let addresses):
                        self.dataHolder = ListDataHolder(data:Observable.just(Array(addresses.prefix(self.numberOfResults))).structured())
                        self.selection.execute(.reload)
                    case .error(let error):
                        print(error)
                        let dispatchTime = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                            var message = "alert_generalError".localized()
                            if Reachability()?.isReachable == false {
                                message = "alert_connectionError".localized()
                            }
                            let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                                alertView.dismissAlertView()
                            })
                            dialog.allowTouchOutsideToDismiss = false
                            dialog.show()
                        }
                    default:
                        break
                    }
                }.addDisposableTo(resultsDispose!)
            }
        } else if text.characters.count == 0 {
            self.getHistoryAndFavorites()
        } else {
            self.dataHolder = ListDataHolder.empty
            self.selection.execute(.reload)
        }
    }
    
    func getHistoryAndFavorites() {
        var historyAndFavorites: [ModelType] = [ModelType]()
        
        var favourites: Bool = false
        var numberOfResults: Int = self.numberOfResults
        if !self.favourites {
            if let array = UserDefaults.standard.object(forKey: "favouritesArray") as? Data {
                if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [FavouriteAddress] {
                    if unarchivedArray.count > 0 {
                        for historyAddress in Array(unarchivedArray.prefix(numberOfResults)) {
                            historyAndFavorites.append(historyAddress.getAddress())
                        }
                        favourites = true
                    }
                }
            }
        }
        if !favourites && !self.favourites {
            historyAndFavorites.append(Favorite.empty1)
        } else if self.favourites {
            historyAndFavorites.append(Favorite.empty2)
        }
        numberOfResults = numberOfResults-historyAndFavorites.count
        if let array = UserDefaults.standard.object(forKey: "historyArray") as? Data {
            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: array) as? [HistoryAddress] {
                if unarchivedArray.count > 0 && self.favourites {
                    historyAndFavorites.removeFirst()
                    numberOfResults -= 1
                }
                for historyAddress in Array(unarchivedArray.prefix(numberOfResults)) {
                    historyAndFavorites.append(historyAddress.getAddress())
                }
            }
        }
        self.dataHolder = ListDataHolder(data:Observable.just(historyAndFavorites).structured())
        self.selection.execute(.reload)
    }
}
