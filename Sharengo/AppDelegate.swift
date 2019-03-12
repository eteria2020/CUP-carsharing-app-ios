
import Gloss
import GoogleMaps
import Firebase
import Localize_Swift
import KeychainSwift
import OneSignal
import RxSwift
import SideMenu
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    private let menuPadding: CGFloat = 100.0
    
    static var isLoggedIn: Bool {
        return username != nil && KeychainSwift().get("Password") != nil
    }
    
    static var username: String? {
        return KeychainSwift().get("Username")
    }
    
    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        FirebaseApp.configure()
        
        if AppDelegate.isLoggedIn && KeychainSwift().get("PasswordClear") == nil
        {
            var languageid = "en"
            if Locale.preferredLanguages[0] == "it-IT"
            {
                languageid = "it"
            }
            Localize.setCurrentLanguage(languageid)
            KeychainSwift().clear()
        }
        
        setupAlert()
        setupHistory()
        setupFavourites()
        setupSettings()
        setupCities()
        setupPolygons()
        setupGoogleMaps()
        setupConfig()
        
        let cc = CoreController.shared
        cc.setup()
        
        TextStyle.setup()
        Router.start(self)
        CoreController.shared.updateData()
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().clipsToBounds = true
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        
        statusBar.backgroundColor = ColorBrand.yellow.value
        self.setupSideMenu()
        
        if let callingAp : NSString = launchOptions?[.sourceApplication] as? NSString
        {
            debugPrint(callingAp)
            CoreController.shared.callingApp = callingAp
        }
        
        //  Enable OneSignal
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "202ca4a0-8ec3-4db3-af38-2986a3138106",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        //  Manage launch options
        
        if let url = launchOptions?[.url] as? URL
        {
            _ = handleURL(url)
        }
        
        if let data = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        {
            PushNotificationController.shared.set(notification: data)
        }
        
//        //    TEST Push Notification
//        if _isDebugAssertConfiguration()
//        {
//            if    let data = try? Data(contentsOf: URL(fileURLWithPath: "/Users/sharengo/Desktop/fake-note.json")),
//                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any],
//                let dict = json
//            {
//                PushNotificationController.shared.set(notification: dict)
//            }
//        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
        //CLICK home button primo
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        //CLICK home button secondo e ultimo
        CoreController.shared.currentViewController?.hideMenuBackground()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        //CLICK app primo
        LocationManager.sharedInstance.locationManager?.stopUpdatingLocation()
        LocationManager.sharedInstance.locationManager?.startUpdatingLocation()
     
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return handleURL(url)
    }
    
    //    MARK: Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        debugPrint("Devices registered: \(deviceToken as NSData)")
    }
    
    // MARK: - Utilities methods
    
    private func setupAlert()
    {
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
    
    private func setupHistory()
    {
        if UserDefaults.standard.object(forKey: "historyDic") == nil {
            UserDefaults.standard.set([String: Data](), forKey: "historyDic")
        }
    }

    private func setupGoogleMaps()
    {
       // #if ISDEBUG
           // GMSServices.provideAPIKey("AIzaSyCrFe8JoIela-xxbetLVbb1VbTsxz88mA8")
       // #elseif ISRELEASE
         //   GMSServices.provideAPIKey("AIzaSyCrFe8JoIela-xxbetLVbb1VbTsxz88mA8")
        //    TODO: ripristinare per l'invio
            GMSServices.provideAPIKey("AIzaSyCnHV6khPUikgREjDIaOfSOOOM8SoI6RlM")
        //#endif
    }
    
    private func setupFavourites()
    {
        if UserDefaults.standard.object(forKey: "favouritesAddressDic") == nil {
            UserDefaults.standard.set([String: Data](), forKey: "favouritesAddressDic")
        }
        
        if UserDefaults.standard.object(forKey: "favouritesFeedDic") == nil {
            UserDefaults.standard.set([String: Data](), forKey: "favouritesFeedDic")
        }
    }
    
    private func setupSettings()
    {
        if UserDefaults.standard.object(forKey: "cityDic") == nil {
            UserDefaults.standard.set([String: String](), forKey: "cityDic")
        }
        
        if UserDefaults.standard.object(forKey: "languageDic") == nil {
            UserDefaults.standard.set([String: String](), forKey: "languageDic")
        }
    }
    
    private func setupCities()
    {
        if let cache = UserDefaults.standard.object(forKey: "cacheCities") as? Data {
            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: cache) as? [CityCache] {
                var cities: [City] = [City]()
                for city in Array(unarchivedArray) {
                    cities.append(city.getCity())
                }
                CoreController.shared.cities = cities
            }
        }
    }
    
    private func setupPolygons()
    {
        if let cache = UserDefaults.standard.object(forKey: "cachePolygons") as? Data {
            if let unarchivedArray = NSKeyedUnarchiver.unarchiveObject(with: cache) as? [PolygonCache] {
                var polygons: [Polygon] = [Polygon]()
                for polygon in Array(unarchivedArray) {
                    polygons.append(polygon.getPolygon())
                }
                CoreController.shared.polygons = polygons
            }
        }
    }
    
    private func setupConfig()
    {
        CoreController.shared.apiController.getConfig()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe {event in
                switch event {
                case .next(let response):
                    if response.status == 200, let data = response.array_data {
                        if let config = [AppConfig].from(jsonArray: data) {
                            config.forEach({ (conf) in
                                CoreController.shared.appConfig[conf.config_key!] = conf.config_value
                            })
               
                        }
                        
                    }
                    break
                case .error(_):
                    print("AppDelegate - setupConfig: error")
                    break
                case .completed:
                    break
                }}
            .addDisposableTo(CoreController.shared.disposeBag)
    }
    
    private func handleURL(_ url: URL) -> Bool
    {
        if url.host == nil
        {
            return true;
        }
        
        let urlString = url.absoluteString
        let queryArray = urlString.components(separatedBy: "/")
        let query = queryArray[2]
        
        // Check if article
        if query.range(of: "plate") != nil
        {
            let data = urlString.components(separatedBy: "/")
            if data.count >= 3
            {
                let parameter = data[3]
                CoreController.shared.urlDeepLink = parameter
                
                return true
            }
        }
        
        return false
    }
    
    func setupSideMenu()
    {
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuShadowColor = .black
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuWidth = UIScreen.main.bounds.width - menuPadding
        SideMenuManager.menuAnimationBackgroundColor = UIColor.red
        
        let menuRightNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuNavigation") as! UISideMenuNavigationController
        SideMenuManager.menuRightNavigationController = menuRightNavigationController
        
        if let menu = menuRightNavigationController.topViewController as? MenuViewController
        {
            menu.bind(to: ViewModelFactory.menu(), afterLoad: true)
        }
    }
}
