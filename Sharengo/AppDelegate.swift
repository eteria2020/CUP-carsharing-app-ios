import UIKit
import Fabric
import Crashlytics
import Boomerang
import RxSwift
import Gloss
import SideMenu
import Localize_Swift
import GoogleMaps
import KeychainSwift

//global var for URL
public var selectedPlate = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    fileprivate let menuPadding: CGFloat = 100.0
    

    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if KeychainSwift().get("Username") == nil || KeychainSwift().get("Password") == nil {
            // Non sono loggato
        } else {
            if KeychainSwift().get("PasswordClear") == nil {
                var languageid = "en"
                if Locale.preferredLanguages[0] == "it-IT" {
                    languageid = "it"
                }
                Localize.setCurrentLanguage(languageid)
                KeychainSwift().clear()
            }
        }
        
        self.setupAlert()
        self.setupHistory()
        self.setupFavourites()
        self.setupSettings()
        self.setupCities()
        self.setupPolygons()
        self.setupGoogleMaps()
        self.setupFabric()
        self.setupConfig()
        _ = CoreController.shared.pulseYellow
        _ = CoreController.shared.pulseGreen
        
        TextStyle.setup()
        Router.start(self)
        CoreController.shared.updateData()
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().clipsToBounds = true
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        
        statusBar.backgroundColor = ColorBrand.yellow.value
        self.setupSideMenu()
        
        if let callingAp : NSString = launchOptions?[.sourceApplication] as? NSString{
            debugPrint(callingAp)
            CoreController.shared.callingApp = callingAp
        }
        
        if let url = launchOptions?[.url] as? URL{
           
        
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
                //let userInfo = [RemoteNotificationDeepLinkAppSectionKey : parameter ]
                //self.applicationHandleRemoteNotification(application, didReceiveRemoteNotification: userInfo)
            }
        }
        
        }
       
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreController.shared.currentViewController?.hideMenuBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        LocationManager.sharedInstance.locationManager?.stopUpdatingLocation()
        LocationManager.sharedInstance.locationManager?.startUpdatingLocation()
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

    fileprivate func setupFabric() {
        #if ISDEBUG
        #elseif ISRELEASE
            Fabric.with([Crashlytics.self])
        #endif
    }

    fileprivate func setupGoogleMaps() {
       // #if ISDEBUG
           // GMSServices.provideAPIKey("AIzaSyCrFe8JoIela-xxbetLVbb1VbTsxz88mA8")
       // #elseif ISRELEASE
         //   GMSServices.provideAPIKey("AIzaSyCrFe8JoIela-xxbetLVbb1VbTsxz88mA8")
        //    TODO: ripristinare per l'invio
            GMSServices.provideAPIKey("AIzaSyCnHV6khPUikgREjDIaOfSOOOM8SoI6RlM")
        //#endif
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
    
    fileprivate func setupCities() {
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
    
    fileprivate func setupPolygons() {
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
    fileprivate func setupConfig(){
        
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
}

/*func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
  
   let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
    let items = (urlComponents?.queryItems)! as [NSURLQueryItem] // {name = backgroundcolor, value = red}
    if (url.scheme == "sharengocar") {
        //var color: UIColor? = nil
        var plate = ""
        if let _ = items.first, let propertyName = items.first?.name, let propertyValue = items.first?.value {
            //vcTitle = propertyName
            if (propertyName == "plate") {
               plate = propertyValue
            }
        }
        
        if (plate != "") {
            selectedPlate = plate
            /*let vc = UIViewController()
            vc.view.backgroundColor = color
            vc.title = vcTitle
            let navController = UINavigationController(rootViewController: vc)
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss))
            vc.navigationItem.leftBarButtonItem = barButtonItem
            self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)*/
            return true
        }
    }
    // URL Scheme entered through URL example : swiftexamples://red
    //swiftexamples://?backgroundColor=red
    return false

}*/
 func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    /*if url.host == nil
    {
        return true;
    }
    
    let urlString = url.absoluteString
    let queryArray = urlString!.components(separatedBy: "/")
    let query = queryArray[2]
    
    // Check if article
    if query.range(of: "plate") != nil
    {
        let data = urlString!.components(separatedBy: "/")
        if data.count >= 3
        {
            let parameter = data[3]
            //let userInfo = [RemoteNotificationDeepLinkAppSectionKey : parameter ]
            //self.applicationHandleRemoteNotification(application, didReceiveRemoteNotification: userInfo)
        }
    }
    
  
        CoreController.shared.urlDeepLink = url
        print(url.host as String!)*/
    if let url = url as? URL{
        
        
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
                //let userInfo = [RemoteNotificationDeepLinkAppSectionKey : parameter ]
                //self.applicationHandleRemoteNotification(application, didReceiveRemoteNotification: userInfo)
            }
        }
        
    }
    
    if let callingApp = options[.sourceApplication]{
        debugPrint(callingApp)
    }
    
    
    return true
}



func presentDetailViewController(plate:String) {
    
    selectedPlate = plate
    
    
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let detailVC = storyboard.instantiateViewController(withIdentifier: "NavigationController")
        as! MapViewController
    
    let navigationVC = storyboard.instantiateViewController(withIdentifier: "DetailController")
        as! UINavigationController
    navigationVC.modalPresentationStyle = .formSheet
    
    navigationVC.pushViewController(detailVC, animated: true)
}

extension AppDelegate {
    func setupSideMenu() {
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuShadowColor = .black
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.width-menuPadding
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.red
        
        let menuRightNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuNavigation") as! UISideMenuNavigationController
        SideMenuManager.default.menuRightNavigationController = menuRightNavigationController
        
        if let menu = menuRightNavigationController.topViewController as? MenuViewController
        {
            //  Use afterLoad to avoid binding problem.
            menu.bind(to: ViewModelFactory.menu(), afterLoad: false)
        }
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {

        // 1
        /*guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
         let url = userActivity.webpageURL,
         let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
         return true
         }
         
         // 2
         let computer = userActivity.webpageURL?.path
         presentDetailViewController(plate: computer!)
         return true
         
         
         // 3*/
        
        /*let topWindow = UIWindow(frame: UIScreen.main.bounds)
        topWindow.rootViewController = UIViewController()
        topWindow.windowLevel = UIWindowLevelAlert + 1
        let alert = UIAlertController(title: "UN LINK", message: "YES", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "confirm"), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            // continue your work
            // important to hide the window after work completed.
            // this also keeps a reference to the window until the action is invoked.
            topWindow.isHidden = true
        }))
        topWindow.makeKeyAndVisible()
        topWindow.rootViewController?.present(alert, animated: true, completion: { _ in })
        
        let webpageUrl = URL(string: "http://rw-universal-links-final.herokuapp.com")!
        application.openURL(webpageUrl)*/
        
        return true
    }

}
