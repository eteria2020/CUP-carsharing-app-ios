import Foundation
import Boomerang
import UIKit
import MediaPlayer
import AVKit

internal extension UIViewController {
    func withNavigation() -> NavigationController {
        let navigationController = NavigationController(rootViewController: self)
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }
}

extension ViewModelBindable where Self : UIViewController {
    func withViewModel(_ viewModel:ViewModelType) -> Self {
        self.bind(to: viewModel, afterLoad: true)
        return self
    }
}

struct Router : RouterType {
    public static func exit<Source>(_ source:Source) where Source: UIViewController{
        _ = source.navigationController?.popToRootViewController(animated: true)
    }
    
    public static func back<Source>(_ source:Source) where Source: UIViewController{
        _ = source.navigationController?.popViewController(animated: true)
    }
    
    public static func dismiss<Source>(_ source:Source) where Source: UIViewController{
        _ = source.dismiss(animated: true, completion: nil)
    }
    
    public static func start(_ delegate:AppDelegate) {
        delegate.window = UIWindow(frame: UIScreen.main.bounds)
        delegate.window?.rootViewController = self.root()
        delegate.window?.makeKeyAndVisible()
    }
    
    public static func confirm<Source:UIViewController>(title:String,message:String,confirmationTitle:String, from source:Source, action:@escaping ((Void)->())) -> RouterAction {
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: confirmationTitle, style: .default, handler: {_ in action()}))
        return UIViewControllerRouterAction.modal(source: source, destination: alert, completion: nil)
    }
    
    public static func actions<Source:UIViewController>(fromSource source:Source, item:UIBarButtonItem, actions:[UIAlertAction]) -> RouterAction {
        let alert = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        _ = actions.reduce(alert) { (accumulator, action)  in
            accumulator.addAction(action)
            return accumulator
        }
        alert.modalPresentationStyle = .popover
        let popover = alert.popoverPresentationController!
        popover.permittedArrowDirections = .up
        popover.barButtonItem = item
        return UIViewControllerRouterAction.modal(source: source, destination: alert, completion: nil)
    }
    
    public static func from<Source> (_ source:Source, viewModel:ViewModelType) -> RouterAction where Source: UIViewController {
        switch viewModel {
        case is SearchCarsViewModel:
            let destination:SearchCarsViewController = (Storyboard.main.scene(.searchCars))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is LoginViewModel:
            let destination: LoginViewController = (Storyboard.main.scene(.login))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is SignupViewModel:
            let destination: SignupViewController = (Storyboard.main.scene(.signup))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is ProfileViewModel:
            let destination: ProfileViewController = (Storyboard.main.scene(.profile))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is HomeViewModel:
            let destination: HomeViewController = (Storyboard.main.scene(.home))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is SettingsViewModel:
            let destination: SettingsViewController = (Storyboard.main.scene(.settings))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is SettingsLanguagesViewModel:
            let destination: SettingsLanguagesViewController = (Storyboard.main.scene(.settingsLanguages))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is SettingsCitiesViewModel:
            let destination: SettingsCitiesViewController = (Storyboard.main.scene(.settingsCities))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is NoFavouritesViewModel:
            let destination: NoFavouritesViewController = (Storyboard.main.scene(.noFavourites))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is NewFavouriteViewModel:
            let destination: NewFavouriteViewController = (Storyboard.main.scene(.newFavourite))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is FavouritesViewModel:
            let destination: FavouritesViewController = (Storyboard.main.scene(.favourites))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is CarTripsViewModel:
            let destination: CarTripsViewController = (Storyboard.main.scene(.carTrips))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is FeedsViewModel:
            let destination: FeedsViewController = (Storyboard.main.scene(.feeds))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is FeedDetailViewModel:
            let destination: FeedDetailViewController = (Storyboard.main.scene(.feedDetail))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        case is NoFeedsViewModel:
            let destination: NoFeedsViewController = (Storyboard.main.scene(.noFeeds))
            destination.bind(to: viewModel, afterLoad: true)
            return UIViewControllerRouterAction.push(source: source, destination: destination)
        default:
            return EmptyRouterAction()
        }
    }

    public static func root() -> UIViewController {
        let destination: HomeViewController = (Storyboard.main.scene(.home))
        destination.bind(to: ViewModelFactory.home(), afterLoad: true)
        return destination.withNavigation()
    }
    
    public static func rootController() -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    public static func restart() {
        UIApplication.shared.keyWindow?.rootViewController = Router.root()
    }

    public static func openApp<Source> (_ url:URL?, from source:Source) -> RouterAction where Source: UIViewController {
        if (url == nil) {return EmptyRouterAction()}
        return UIViewControllerRouterAction.custom(action: {
            UIApplication.shared.openURL(url!)
        })
    }
    
    public static func playVideo<Source> (_ url:URL?, from source:Source) -> RouterAction where Source: UIViewController {
        guard let urlFormatted:URL = URL(string:url?.absoluteString.removingPercentEncoding ?? "") else {
            return EmptyRouterAction()
        }
        let playerController = AVPlayerViewController()
        let asset:AVURLAsset = AVURLAsset(url: urlFormatted, options: [:])
        return UIViewControllerRouterAction.modal(source: source, destination: playerController, completion: {
            let playerItem:AVPlayerItem =  AVPlayerItem(asset: asset)
            playerController.player = AVPlayer(playerItem: playerItem)
            playerController.player?.play()
        })
    }
}
