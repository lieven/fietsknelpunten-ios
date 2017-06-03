//
//  CLPlacemark+FormattedAddress.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 28/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import CoreLocation
import Contacts


extension CLPlacemark
{
	func formattedAddress() -> String?
	{
		return CNPostalAddressFormatter.string(from: CNMutablePostalAddress(placemark: self), style: .mailingAddress)
	}
}

extension CNMutablePostalAddress
{
	convenience init(placemark: CLPlacemark)
	{
		self.init()
		
		
		self.street = (placemark.subThoroughfare ?? "") + " " + (placemark.thoroughfare ?? "")
		self.city = placemark.locality ?? ""
		self.state = placemark.administrativeArea ?? ""
		self.postalCode = placemark.postalCode ?? ""
		self.country = placemark.country ?? ""
	}
}


