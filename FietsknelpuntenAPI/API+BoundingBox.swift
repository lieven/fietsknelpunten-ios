//
//  API+BoundingBox.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 20/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import MapKit


extension API
{
	public func getBoundingBox(completion: @escaping (Bool, MKCoordinateRegion?, Error?)->())
	{
		self.sendRequest(action: "bbox", arguments: nil)
		{
			(success, response, error) in
			
			if success
			{
				if let regionDict = response as? [AnyHashable: Any], let region = MKCoordinateRegion(dictionary: regionDict)
				{
					completion(true, region, nil)
				}
				else
				{
					completion(false, nil, nil)
				}
			}
			else
			{
				completion(false, nil, error)
			}
		}
	}
}

extension MKCoordinateRegion
{
	init?(dictionary: [AnyHashable:Any])
	{
		guard let minLat = dictionary.double(forKey: "minLat", allowConversion: true),
			let minLon = dictionary.double(forKey: "minLon", allowConversion: true),
			let maxLat = dictionary.double(forKey: "maxLat", allowConversion: true),
			let maxLon = dictionary.double(forKey: "maxLon", allowConversion: true) else
		{
			return nil
		}
		
		let centerLat = 0.5*(minLat + maxLat)
		let centerLon  = 0.5*(minLon + maxLon)
		let latDelta = abs(maxLat - minLat)
		let lonDelta = abs(maxLon - minLon)
		
		self.init(center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon), span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
	}
}
