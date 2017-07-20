import UIKit
import Fabric
import Crashlytics
import Boomerang
import RxSwift
import Gloss
import SideMenu
import Localize_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    fileprivate let menuPadding: CGFloat = 100.0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.setupAlert()
        self.setupHistory()
        self.setupFavourites()
        self.setupSettings()
        #if ISDEBUG
        #elseif ISRELEASE
            Fabric.with([Crashlytics.self])
        #endif
        TextStyle.setup()
        Router.start(self)
        CoreController.shared.updateData()
        
        self.setupSideMenu()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        LocationController.shared.locationManager.stopUpdatingLocation()
        LocationController.shared.locationManager.startUpdatingLocation()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    // MARK: - Utilities methods
    
    fileprivate func setupAlert() {
        UserDefaults.standard.set(false, forKey: "alertShowed")
        ZAlertView.positiveColor = Color.alertButtonsPositiveBackground.value
        ZAlertView.negativeColor = Color.alertButtonsPositiveBackground.value
        ZAlertView.backgroundColor = Color.alertBackground.value
        ZAlertView.messageColor = Color.alertMessage.value
        ZAlertView.buttonTitleColor = Color.alertButton.value
        ZAlertView.messageFont = Font.alertMessage.value
        ZAlertView.buttonFont = Font.alertButton.value
        ZAlertView.blurredBackground = false
        ZAlertView.showAnimation = .bounceTop
        ZAlertView.hideAnimation = .bounceBottom
        ZAlertView.initialSpringVelocity = 0.9
        ZAlertView.duration = 2
        ZAlertView.buttonSectionExtraGap = 20
    }
    
    fileprivate func setupHistory() {
        if UserDefaults.standard.object(forKey: "historyDic") == nil {
            UserDefaults.standard.set([String: Data](), forKey: "historyDic")
        }
    }
    
    fileprivate func setupFavourites() {
        if UserDefaults.standard.object(forKey: "favouritesAddressDic") == nil {
            UserDefaults.standard.set([String: Data](), forKey: "favouritesAddressDic")
        }
        
        if UserDefaults.standard.object(forKey: "favouritesFeedDic") == nil {
            UserDefaults.standard.set([String: Data](), forKey: "favouritesFeedDic")
        }
    }
    
    fileprivate func setupSettings() {
        if UserDefaults.standard.object(forKey: "cityDic") == nil {
            UserDefaults.standard.set([String: String](), forKey: "cityDic")
        }
        
        if UserDefaults.standard.object(forKey: "languageDic") == nil {
            UserDefaults.standard.set([String: String](), forKey: "languageDic")
        }
    }
}

extension AppDelegate {
    func setupSideMenu() {
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuShadowColor = .black
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuWidth = UIScreen.main.bounds.width-menuPadding
        SideMenuManager.menuAnimationBackgroundColor = UIColor.red
        
        let menuRightNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuNavigation") as! UISideMenuNavigationController
        SideMenuManager.menuRightNavigationController = menuRightNavigationController
        if let menu = menuRightNavigationController.topViewController as? MenuViewController
        {
            menu.bind(to: ViewModelFactory.menu(), afterLoad: true)
        }
        
        SideMenuManager.menuRightNavigationController = menuRightNavigationController
    }
}
