//
//  PushNotificationController.swift
//  PUSH
//
//  Created by Dimitri Giani on 22/06/2018.
//  Copyright © 2018 Nice APP. All rights reserved.
//

import OneSignal
import UIKit
import UserNotifications

extension Notification.Name
{
    static let PushStatusChanged = Notification.Name("PushStatusChanged")
}

class PushNotificationController: NSObject
{
    enum PushType: Int {
        case openApp
        case openTripHistory
        case openMap
        case openGenericWebView
    }
    
	static let shared = PushNotificationController()
    
    
    public var externalUrl: String?
    static let usernameOneSignalTag = "username"
    static let pushNotificationAuthorizedKey = "pushNotificationAuthorized"
    static var pushNotificationIsRefused: Bool {
        let isRefused = !OneSignal.getPermissionSubscriptionState().subscriptionStatus.subscribed
        
        return pushNotificationHasPrompted && isRefused
    }
    
    static var pushNotificationHasPrompted: Bool {
        let hasPrompted = OneSignal.getPermissionSubscriptionState().permissionStatus.hasPrompted
        return hasPrompted
    }
    
	private var lastNotification: [AnyHashable: Any]?
    
    func requestPushNotifications()
    {
        guard AppDelegate.isLoggedIn else { return }
        
        if #available(iOS 10.0, *)
        {
            UNUserNotificationCenter.current().delegate = self
        }
        
        OneSignal.add(self as OSPermissionObserver)
        OneSignal.promptForPushNotifications(userResponse: { [unowned self] accepted in
            debugPrint("PushNotificationController: User accepted notifications: \(accepted)")
            
            NotificationCenter.default.post(name: .PushStatusChanged, object: nil, userInfo: [PushNotificationController.pushNotificationAuthorizedKey: accepted])
            
            if accepted
            {
                self.sendOneSignalTag()
            }
        })
    }
    
    func removePushNotifications()
    {
        UIApplication.shared.unregisterForRemoteNotifications()
        removeOneSignalTag()
    }
    
	func set(notification: [AnyHashable: Any])
	{
		lastNotification = notification
	}
	
	func evaluateLastNotification(from viewController: UIViewController? = nil)
	{
      //  debugPrint("Evaluate: \(String(describing: lastNotification))")
        
        guard   let custom = lastNotification?["custom"] as? [String: Any],
                let a = custom["a"] as? [String: Any],
                let ts = a["t"] as? Int else { return }
        
        let type = PushType(rawValue: ts) ?? .openApp
        
        externalUrl = a["l"] as? String
      
        
        switch type
        {
        case .openApp: break
        case .openTripHistory:
            guard AppDelegate.isLoggedIn else { return }
            
            Router.backCurrentControllerToRoot() {
                Router.openTripHistory()
            }
            
        case .openMap:
            guard AppDelegate.isLoggedIn else { return }
            
            Router.backCurrentControllerToRoot() {}
            
          case .openGenericWebView:
            Router.backCurrentControllerToRoot() {
                Router.openGenericWebView()
            }
        }
        
      
        
        
        lastNotification = nil
	}

    func sendOneSignalTag()
    {
        if !PushNotificationController.pushNotificationIsRefused, let username = AppDelegate.username?.removingPercentEncoding
        {
            OneSignal.sendTags([PushNotificationController.usernameOneSignalTag: username])
        }
    }
    
    func removeOneSignalTag()
    {
        OneSignal.deleteTag(PushNotificationController.usernameOneSignalTag)
    }
}

extension PushNotificationController: UNUserNotificationCenterDelegate
{
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        //    In questo momento l'app è avviata, quindi possiamo valutare la notifica
        
        set(notification: response.notification.request.content.userInfo)
        evaluateLastNotification()
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        set(notification: userInfo)
        
        //    In questo momento l'app potrebbe essere in background, quindi possiamo valutare la notifica solo se è attiva
        
        if application.applicationState == .active
        {
            evaluateLastNotification()
        }
        
        completionHandler(.newData)
    }
}

extension PushNotificationController: OSPermissionObserver
{
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!)
    {
        if stateChanges.from.status == OSNotificationPermission.notDetermined
        {
            if stateChanges.to.status == OSNotificationPermission.authorized
            {
                debugPrint("Thanks for accepting notifications!")
            }
            else if stateChanges.to.status == OSNotificationPermission.denied
            {
                debugPrint("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        
        // prints out all properties
        //debugPrint("PermissionStateChanges: \n\(stateChanges)")
        
        NotificationCenter.default.post(name: .PushStatusChanged, object: nil, userInfo: [
            PushNotificationController.pushNotificationAuthorizedKey: stateChanges.to.status == .authorized
        ])
    }
}
