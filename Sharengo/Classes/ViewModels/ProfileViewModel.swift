//
//  ProfileViewModel.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import Action

enum ProfileSelectionInput: SelectionInput {
}

enum ProfileSelectionOutput: SelectionOutput {
    case viewModel(ViewModelType)
    case empty
}

struct ProfileTableViewCellStruct
{
    var title = ""
    
    init(title: String)
    {
        self.title = title
    }
}

final class ProfileViewModel: ViewModelType {
    let cellsArray: [ProfileTableViewCellStruct]

    init() {
        let cell1 = ProfileTableViewCellStruct(title: "lbl_profileCellTitle1".localized())
        let cell2 = ProfileTableViewCellStruct(title: "lbl_profileCellTitle2".localized())
        let cell3 = ProfileTableViewCellStruct(title: "lbl_profileCellTitle3".localized())
        let cell4 = ProfileTableViewCellStruct(title: "lbl_profileCellTitle4".localized())
        
        cellsArray = [cell1, cell2, cell3, cell4]
    }
}
