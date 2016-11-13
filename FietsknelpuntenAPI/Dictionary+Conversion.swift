//
//  Dictionary+Conversion.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import Foundation


extension Dictionary
{
	public func string(forKey key: Key, allowConversion: Bool = false, defaultValue: String? = nil) -> String?
	{
		guard let value = self[key] else
		{
			return defaultValue
		}
		
		if let stringValue = value as? String
		{
			return stringValue
		}
		else if allowConversion
		{
			return "\(value)"
		}
		else
		{
			return defaultValue
		}
	}
}
