//
//  ProfileViewController.swift
//  Sharengo
//
//  Created by Dedecube on 13/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang

class ProfileViewController : UIViewController, ViewModelBindable {
    @IBOutlet fileprivate weak var view_navigationBar: NavigationBarView!
    @IBOutlet fileprivate weak var view_top: UIView!
    @IBOutlet fileprivate weak var tblView_main: UITableView!
    
    var viewModel: ProfileViewModel?
    
    // MARK: - ViewModel methods
    
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? ProfileViewModel else {
            return
        }
        self.viewModel = viewModel
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.view.backgroundColor = Color.profileBackground.value
        
        // NavigationBar
        self.view_navigationBar.bind(to: ViewModelFactory.navigationBar(leftItemType: .home, rightItemType: .menu))
        self.view_navigationBar.viewModel?.selection.elements.subscribe(onNext:{[weak self] output in
            if (self == nil) { return }
            switch output {
            case .home:
                Router.exit(self!)
            case .menu:
                print("Open menu")
                break
            default:
                break
            }
        }).addDisposableTo(self.disposeBag)
    }
}

// MARK: - Table View datasource

extension ProfileViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if viewModel != nil
        {
            return self.viewModel!.cellsArray.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell") as! ProfileTableViewCell
        
        if viewModel != nil
        {
            let viewModel = self.viewModel!.cellsArray[indexPath.row]
            cell.setupWith(title: viewModel.title)
            
            if indexPath.row % 2 == 0
            {
                cell.backgroundColor = UIColor.white
            }
            else
            {
                cell.backgroundColor = UIColor.lightGray
            }
            
            return cell
        }
        
        return cell
    }
}

// MARK: - Table View delegate

extension ProfileViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if viewModel != nil
        {
            return self.tblView_main.frame.size.height / CGFloat(self.viewModel!.cellsArray.count)
        }
        
        return 0
    }
}
