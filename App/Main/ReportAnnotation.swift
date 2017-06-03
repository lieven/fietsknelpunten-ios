//
//  ReportAnnotation.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 28/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import MapKit


class ReportAnnotation: NSObject, MKAnnotation
{
	var report: Report
	
	init(report: Report)
	{
		self.report = report
		super.init()
		
		self.placemark = nil
	}
	
	var title: String?
	{
		if let title = report.title
		{
			return title
		}
		
		let tagsString = report.tagsString()
		if tagsString.characters.count > 0
		{
			return tagsString
		}
		
		return NSLocalizedString("NEW_REPORT_ANNOTATION_TITLE", value: "New Report", comment: "Title for a map annotation for a new report when no title has been chosen yet. Should be short.")
	}
	
	var coordinate: CLLocationCoordinate2D
	{
		get
		{
			return report.coordinate
		}
		set
		{
			report.coordinate = newValue
		}
	}
	
	var subtitle: String?
	
	var placemark: CLPlacemark?
	{
		didSet
		{
			if let placemark = placemark, let postalCode = placemark.postalCode, let countryCode = placemark.isoCountryCode
			{
				report.countryCode = countryCode
				report.postalCode = postalCode
				
				if let street = placemark.thoroughfare, let city = placemark.locality
				{
					subtitle = "\(street), \(postalCode) \(city)"
				}
				else if let name = placemark.name
				{
					subtitle = name
				}
			}
			else
			{
				report.countryCode = nil
				report.postalCode = nil
				
				subtitle = NSLocalizedString("NEW_REPORT_PIN_SUBTITLE", value:"Drag to exact location", comment: "Subtitle for new report pins on the map. Should be short.")
			}
		}
	}
}
