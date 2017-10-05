//
//  NotificationCenter+Extensions.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

/**
Notification center utilities
 */
public extension NotificationCenter
{
    /**
     This method post a notification from name and object (if present)
     - Parameter name: notification's name
     - Parameter object: object to be attach with notification
     */
	public static func post(notificationWithName name:Notification.Name, object: Any? = nil)
	{
		NotificationCenter.default.post(name: name, object: object, userInfo: nil)
	}

    /**
     This method post a notification from name, object (if present) and userInfo dictionary
     - Parameter name: notification's name
     - Parameter object: object to be attach with notification
     - Parameter userInfo: dictionary with format String:Any
     */
	public static func post(notificationWithName name:Notification.Name, object: Any? = nil, userInfo:[String:Any])
	{
		NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
	}
	
    /**
     This method post a notification from name, object (if present) and error
     - Parameter name: notification's name
     - Parameter object: object to be attach with notification
     - Parameter error: error inserted in userInfo dictionary with key NotificationError
     */
	public static func post(notificationWithName name:Notification.Name, object: Any? = nil, error:Error)
	{
		NotificationCenter.default.post(name: name, object: object, userInfo: ["NotificationError": error])
	}
	
    /**
     This method observe a notification with a Closure
     - Parameter name: notification's name
     - Parameter from: object to be attach with notification
     - Parameter closure: closure used to observe notification
     */
	public static func observe(notificationWithName name:Notification.Name, _ from:Any? = nil, _ closure: @escaping (Notification)->Void)
	{
		NotificationCenter.default.addObserver(forName: name, object: from, queue: nil, using: closure)
	}
	
    /**
     This method observe a notification with a Selector
     - Parameter observer: observer's object
     - Parameter name: notification's name
     - Parameter from: object to be attach with notification
     - Parameter selector: selector to be used
     */
	public static func add(observer:Any, forName name:Notification.Name, from:AnyObject?, selector:Selector)
	{
		NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: from)
	}
	
    /**
     This method remove a notification
     - Parameter observer: observer's object
     - Parameter notification: notification's object
     */
	public static func remove(observer:Any, forNotification notification:Notification)
	{
		NotificationCenter.default.removeObserver(observer, name: notification.name, object: notification.object)
	}
	
}
