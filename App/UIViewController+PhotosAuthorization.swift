//
//  UIViewController+PhotosAuthorization.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 14/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit
import Photos


extension UIViewController
{
	func checkPhotosAuthorization(denied: (()->())? = nil, authorized: @escaping ()->())
	{
		let status = PHPhotoLibrary.authorizationStatus()
		
		let handleDeterminedStatus =
		{
			[weak self] (status: PHAuthorizationStatus) in
			
			switch status
			{
				case .authorized:
					authorized()
				
				case .restricted: fallthrough
				case .denied:
					
					if let denied = denied
					{
						denied()
					}
					else
					{
						self?.showPhotosAuthorizationDeniedAlert()
					}
				
				default:
					break
			}
		}
		
		if status == .notDetermined
		{
			PHPhotoLibrary.requestAuthorization(handleDeterminedStatus)
		}
		else
		{
			handleDeterminedStatus(status)
		}
	}
	
	private func showPhotosAuthorizationDeniedAlert()
	{
		let title = NSLocalizedString("PHOTOS_DENIED_TITLE", value: "Photos Access Disabled", comment: "Title for the alert shown when a user wants to use photos from their library but has previously denied access. Should be short.")
		let message = NSLocalizedString("PHOTOSO_DENIED_MESSAGE", value: "Photo library access is disabled for this application. You can change this in Settings > Privacy > Photos", comment: "Alert message shown when a user wants to use photos from their library but has previously denied access")
		let OK = NSLocalizedString("OK_BUTTON", value: "OK", comment: "OK Button. Should be very short.")
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: OK, style: .default, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
}
