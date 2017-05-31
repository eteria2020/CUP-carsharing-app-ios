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

enum SearchBarSelectionInput: SelectionInput {
    case item(IndexPath)
}
enum SearchBarSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
}

final class SearchBarViewModel: ListViewModelType, ViewModelTypeSelectable {
    var dataHolder: ListDataHolderType = ListDataHolder()
    fileprivate var resultsDispose: DisposeBag?
    fileprivate var apiController: NominatimAPIController = NominatimAPIController()
    
    lazy var selection:Action<SearchBarSelectionInput,SearchBarSelectionOutput> = Action { input in
        return .empty()
    }
    
    init() {
    }
    
    // MARK: - Address methods
    
    func stopRequest() {
        self.resultsDispose = nil
        self.resultsDispose = DisposeBag()
    }
    
    func reloadResults(text: String) {
        self.apiController.searchAddress()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.data {
//                        if let cars = [Car].from(jsonArray: data) {
//                            self.cars = cars.filter({ (car) -> Bool in
//                                return car.status == .operative
//                            })
//                            self.manageAnnotations()
//                            return
//                        }
                    }
//                    self.cars.removeAll()
//                    self.manageAnnotations()
                case .error(_):
                    let dispatchTime = DispatchTime.now() + 0.5
                    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                        var message = "lbl_generalError".localized()
                        if Reachability()?.isReachable == false {
                            message = "lbl_connectionError".localized()
                        }
                        let dialog = ZAlertView(title: nil, message: message, closeButtonText: "btn_ok".localized(), closeButtonHandler: { alertView in
                            alertView.dismissAlertView()
                        })
                        dialog.allowTouchOutsideToDismiss = false
                        dialog.show()
//                        self.cars.removeAll()
//                        self.manageAnnotations()
                    }
                default:
                    break
                }
            }.addDisposableTo(resultsDispose!)
    }
}
