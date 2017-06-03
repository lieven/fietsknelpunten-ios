//
//  API+Jurisdiction.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 28/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import Foundation


extension API
{
	public func getAllJurisdictions(completion: @escaping (Bool, [Jurisdiction]?, Error?)->())
	{
		sendRequest(action: "allJurisdictions", arguments: [:])
		{
			(success, response, error) in
			
			if success, let jurisdictionDicts = response as? [Any]
			{
				var jurisdictions = [Jurisdiction]()
				
				for jurisdictionDict in jurisdictionDicts
				{
					if let jurisdictionDict = jurisdictionDict as? [String: Any], let jurisdiction = Jurisdiction(dictionary: jurisdictionDict)
					{
						jurisdictions.append(jurisdiction)
					}
				}
				
				completion(true, jurisdictions, nil)
			}
			else
			{
				completion(false, nil, error)
			}
		}
	}
}
			


extension Jurisdiction
{
	internal init?(dictionary: [String: Any])
	{
		guard let identifier = dictionary.string(forKey: "id", allowConversion: true, defaultValue: nil),
			let name = dictionary["name"] as? String,
			let countryCode = dictionary["country"] as? String,
			let postalCodes = dictionary["postalcodes"] as? [String]
		else
		{
			return nil
		}
		
		let info = dictionary["description"] as? String;
		let types = dictionary["types"] as? [String]
		
		self.init(identifier: identifier, name: name, countryCode: countryCode, postalCodes: postalCodes, info: info, types: types)
	}
}
