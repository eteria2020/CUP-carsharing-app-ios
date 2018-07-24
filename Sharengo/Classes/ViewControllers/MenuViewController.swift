//
//  MenuViewController.swift
//  Sharengo
//
//  Created by Dedecube on 20/06/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import KeychainSwift
import SideMenu
import Localize_Swift

/**
 The Menu class shows a panel that displays the app's main navigation options. If the user logs in, this class shows different options and different header message
 */
public class MenuViewController : UIViewController, ViewModelBindable, UICollectionViewDelegateFlowLayout {
    @IBOutlet fileprivate weak var view_header: UIView!
    @IBOutlet fileprivate weak var lbl_welcome: UILabel!
    @IBOutlet fileprivate weak var lbl_version: UILabel!
    @IBOutlet fileprivate weak var view_userIcon: UIView!
    @IBOutlet fileprivate weak var img_userIcon: UIImageView!
    @IBOutlet fileprivate weak var view_separator: UIView!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var btn_profileEco: UIButton!
    /// ViewModel variable used to represents the data
    public var viewModel: MenuViewModel?
    /// Variable used to save if the intro is already showed
    public var introIsShowed: Bool = false
    /// Variable used to save if the animation is already executed
    public var executeAnimation: Bool = true
    /// User can open profile eco status
    public var profileEcoStatusAvailable: Bool = false
    fileprivate var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    let version: Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
    let build: Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")

    // MARK: - ViewModel methods
    
    public func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? MenuViewModel else {
            return
        }
        viewModel.selection.elements.subscribe(onNext: { selection in
            switch selection {
            case .viewModel(let viewModel):
                switch viewModel {
                case is LoginViewModel:
                    let destination: LoginViewController = (Storyboard.main.scene(.login))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is SignupViewModel:
                    let destination: SignupViewController = (Storyboard.main.scene(.signup))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is MapViewModel:
                    let destination: MapViewController = (Storyboard.main.scene(.map))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is ProfileViewModel:
                    let destination: ProfileViewController = (Storyboard.main.scene(.profile))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is CarTripsViewModel:
                    Router.openTripHistory()
                case is SettingsViewModel:
                    let destination: SettingsViewController = (Storyboard.main.scene(.settings))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is InviteFriendViewModel:
                    let destination: InviteFriendViewController = (Storyboard.main.scene(.inviteFriend))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is SupportViewModel:
                    let destination: SupportViewController = (Storyboard.main.scene(.support))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is FaqViewModel:
                    let destination: FaqViewController = (Storyboard.main.scene(.faq))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is UserAreaViewModel:
                    let destination: UserAreaViewController = (Storyboard.main.scene(.userArea))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is RatesViewModel:
                    let destination: RatesViewController = (Storyboard.main.scene(.rates))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is PinViewModel:
                    let destination: PinViewController = (Storyboard.main.scene(.pin))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                case is LegalNoteViewModel:
                    let destination: LegalNoteViewController = (Storyboard.main.scene(.legalNote))
                    destination.bind(to: viewModel, afterLoad: true)
                    CoreController.shared.currentViewController?.navigationController?.pushViewController(destination, animated: false)
                default:
                    break
                }
                case .logout:
                    let message = "lbl_logoutMessage".localized()
                    let dialog = ZAlertView(title: nil, message: message, isOkButtonLeft: false, okButtonText: "lbl_logoutConfirmButton".localized(), cancelButtonText: "btn_cancel".localized(),
                                            okButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                                                var languageid = "en"
                                                if Locale.preferredLanguages[0] == "it-IT" {
                                                    languageid = "it"
                                                }
                                                Localize.setCurrentLanguage(languageid)
                                                KeychainSwift().clear()
                                                PushNotificationController.shared.removePushNotifications()
                                                CoreController.shared.currentCarBooking = nil
                                                CoreController.shared.currentCarTrip = nil
                                                CoreController.shared.allCarBookings = []
                                                CoreController.shared.allCarTrips = []
                                                
                                                NotificationCenter.default.post(name: .PushStatusChanged, object: nil)
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateData"), object: nil)
                                                let dispatchTime = DispatchTime.now() + 0.3
                                                DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
                                                    Router.exit(CoreController.shared.currentViewController ?? self)
                                                    self.updateData()
                                                }
                                               
                    },
                                            cancelButtonHandler: { alertView in
                                                alertView.dismissAlertView()
                    })
                    dialog.allowTouchOutsideToDismiss = false
                    dialog.show()
               
            default: break
            }
            self.executeAnimation = false
            CoreController.shared.currentViewController?.hideMenuBackground()
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(self.disposeBag)
        self.viewModel = viewModel
        self.collectionView?.bind(to: viewModel)
        self.collectionView?.delegate = self
        self.view_userIcon.backgroundColor = UIColor.clear
        self.view_userIcon.layer.cornerRadius = self.view_userIcon.frame.size.width/2
        self.view_userIcon.layer.masksToBounds = true
        self.view_userIcon.layer.borderWidth = 1
        self.view_userIcon.layer.borderColor = Color.menuProfile.value.cgColor
        self.btn_profileEco.rx.bind(to: viewModel.selection, input: .profileEco)
        self.updateData()
        NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.updateData), name: NSNotification.Name(rawValue: "updateData"), object: nil)
    }
    
    // MARK: - View methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.view.backgroundColor = Color.menuBackBackground.value
        self.view_header.backgroundColor = Color.menuTopBackground.value
        self.view_userIcon.isHidden = true
        self.img_userIcon.isHidden = true
        self.btn_profileEco.isHidden = true
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.executeAnimation = true
        if animated {
            CoreController.shared.currentViewController?.showMenuBackground()
        }
        
        updateData()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if animated && self.executeAnimation {
            CoreController.shared.currentViewController?.hideMenuBackground()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Update methods
    
    /**
     This method is linked to a notification with name "updateData". When other methods calls this "updateData" the menu updates its options
     */
    @objc public func updateData() {
        DispatchQueue.main.async {
            self.viewModel?.updateData()
            self.viewModel?.reload()
            self.collectionView?.reloadData()
            self.view.layoutIfNeeded()
            self.lbl_welcome.styledText = self.viewModel?.welcome
            self.lbl_version.styledText = "Ver. \(self.version!) (\(self.build!))"
            self.lbl_version.textColor = UIColor.lightGray
            self.lbl_version.textAlignment = NSTextAlignment.right
            self.lbl_version.font.withSize(9.0)
            if self.profileEcoStatusAvailable {
                self.view_userIcon.isHidden = self.viewModel?.userIconIsHidden ?? true
                self.img_userIcon.isHidden = self.viewModel?.userIconIsHidden ?? true
                self.btn_profileEco.isHidden = self.viewModel?.userIconIsHidden ?? true
            }
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
//        let size = collectionView.autosizeItemAt(indexPath: indexPath, constrainedToWidth: Float(collectionView.frame.size.width))
        let size = collectionView.autosizeItemAt(indexPath: indexPath, itemsPerLine: 1)
        let height = max(54, (UIScreen.main.bounds.height-76)/9)
        return CGSize(width: size.width, height: height)
    }
    
    /**
     This method is called from collection delegate when an option of the list is selected
     */
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.selection.execute(.item(indexPath))
    }
}
