//
//  LocationController.swift
//
//  Created by Dedecube on 22/05/17.
//  Copyright © 2017 Dedecube. All rights reserved.
//

import UIKit

extension NotificationCenter
{
	static func post(notificationWithName name:Notification.Name, object: Any? = nil)
	{
		NotificationCenter.default.post(name: name, object: object, userInfo: nil)
	}
	
	static func post(notificationWithName name:Notification.Name, object: Any? = nil, userInfo:[String:Any])
	{
		NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
	}
	
	static func post(notificationWithName name:Notification.Name, object: Any? = nil, error:Error)
	{
		NotificationCenter.default.post(name: name, object: object, userInfo: ["NotificationError": error])
	}
	
	static func observe(notificationWithName name:Notification.Name, _ from:Any? = nil, _ closure: @escaping (Notification)->Void)
	{
		NotificationCenter.default.addObserver(forName: name, object: from, queue: nil, using: closure)
	}
	
	static func add(observer:Any, forName name:Notification.Name, from:AnyObject?, selector:Selector)
	{
		NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: from)
	}
	
	static func remove(observer:Any, forNotification notification:Notification)
	{
		NotificationCenter.default.removeObserver(observer, name: notification.name, object: notification.object)
	}
	
}
