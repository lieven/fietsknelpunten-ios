//
//  UIViewController+LocationAuthorization.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit
import CoreLocation


extension UIViewController
{
	func checkLocationAuthorization(denied: (()->())? = nil, authorized: @escaping ()->())
	{
		switch CLLocationManager.authorizationStatus()
		{
			case .notDetermined:
				UIViewController.requestAuthorization()
				{
					(status) in
					
					if status == .authorizedAlways || status == .authorizedWhenInUse
					{
						authorized()
					}
				}
			
			case .denied:
				if let denied = denied
				{
					denied()
				}
				else
				{
					presentLocationDeniedAlert()
				}
				
			default:
				authorized()
		}
	}
	
	private func presentLocationDeniedAlert()
	{
		let title = NSLocalizedString("LOCATION_DENIED_TITLE", value: "Location Disabled", comment: "Title for the alert shown when a user wants to use location services but has previously denied access. Should be short.")
		let message = NSLocalizedString("LOCATION_DENIED_MESSAGE", value: "Location Services is disabled for this application. You can change this in Settings > Privacy > Location Services", comment: "Alert message shown when a user wants to use location services but has previously denied access")
		let OK = NSLocalizedString("OK_BUTTON", value: "OK", comment: "OK Button. Should be very short.")
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: OK, style: .default, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
	
	private class LocationAuthorizationDelegate: NSObject, CLLocationManagerDelegate
	{
		func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
		{
			for completionBlock in completionBlocks
			{
				completionBlock(status)
			}
			completionBlocks.removeAll()
		}
		
		var completionBlocks = [(CLAuthorizationStatus)->()]()
	}
	
	private static let locationAuthorizationManager = CLLocationManager()
	private static let locationAuthorizationDelegate = LocationAuthorizationDelegate()
	
	private static func requestAuthorization(completion: @escaping (CLAuthorizationStatus)->())
	{
		locationAuthorizationManager.delegate = locationAuthorizationDelegate
		
		locationAuthorizationDelegate.completionBlocks.append(completion)
		locationAuthorizationManager.requestWhenInUseAuthorization()
	}
}