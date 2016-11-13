//
//  Report.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import FietsknelpuntenAPI
import CoreLocation


class Report
{
	var title: String?
	var info: String?
	var tags = [Tag]()
	var coordinate: CLLocationCoordinate2D?
	
	func tagsString() -> String
	{
		return self.tags.reduce("") {
			$0.characters.count > 0 ? "\($0), \($1.name)" : $1.name
		}
	}
}
