//
//  AppDelegate.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 11/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		
		let navigationController = EditingNavigationController(rootViewController: MainViewController())
		navigationController.isToolbarHidden = false
		
		let window = UIWindow()
		window.tintColor = UIColor(red: 0.732, green: 0.23, blue: 0.23, alpha: 1.0)
		window.rootViewController = navigationController
		self.window = window
		
		window.makeKeyAndVisible()
		
		return true
	}

}
