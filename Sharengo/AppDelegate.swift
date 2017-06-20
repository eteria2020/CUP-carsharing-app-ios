import UIKit
import Fabric
import Crashlytics
import Boomerang
import RxSwift
import Gloss

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.setupAlert()
        self.setupHistory()
        #if ISDEBUG
        #elseif ISRELEASE
            Fabric.with([Crashlytics.self])
        #endif
        TextStyle.setup()
        Router.start(self)
        CoreController.shared.updateData()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
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
        if UserDefaults.standard.object(forKey: "historyArray") == nil {
            let archivedArray = NSKeyedArchiver.archivedData(withRootObject: [HistoryAddress]() as Array)
            UserDefaults.standard.set(archivedArray, forKey: "historyArray")
        }
    }
}

