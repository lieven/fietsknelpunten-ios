//
//  Report.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import FietsknelpuntenAPI
import CoreLocation
import UIKit


class Report
{
	var coordinate: CLLocationCoordinate2D
	var countryCode: String?
	var postalCode: String?
	
	var title: String?
	var info: String?
	var tags = [Tag]()
	var jurisdiction: Jurisdiction?
	var images = [UIImage]()
	
	func tagsString() -> String
	{
		return self.tags.reduce("") {
			$0.count > 0 ? "\($0), \($1.name)" : $1.name
		}
	}
	
	init(coordinate: CLLocationCoordinate2D, image: UIImage? = nil)
	{
		self.coordinate = coordinate
		
		if let image = image
		{
			images.append(image)
		}
	}
}
