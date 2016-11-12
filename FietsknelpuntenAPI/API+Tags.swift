//
//  API+Tags.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 12/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import Foundation


extension API
{
	public func getTags(completion: @escaping (Bool, [TagGroup]?, Error?)->())
	{
		self.sendRequest(action: "tags", arguments: nil)
		{
			(success, response, error) in
			
			if success
			{
				if let groupDicts = response as? [[AnyHashable: Any]]
				{
					var groups = [TagGroup]()
					
					for groupDict in groupDicts
					{
						if let group = TagGroup(dictionary: groupDict)
						{
							groups.append(group)
						}
					}
					
					completion(true, groups, nil)
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

extension Dictionary
{
	func string(forKey key: Key, allowConversion: Bool = false, defaultValue: String? = nil) -> String?
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

extension Tag
{
	convenience init?(dictionary: [AnyHashable: Any])
	{
		guard let identifier = dictionary.string(forKey: "id", allowConversion: true), let name = dictionary["name"] as? String else
		{
			return nil
		}
		
		self.init(identifier: identifier, name: name, info: dictionary["info"] as? String)
	}
}

extension TagGroup
{
	convenience init?(dictionary: [AnyHashable: Any])
	{
		guard let identifier = dictionary.string(forKey: "id", allowConversion: true), let name = dictionary["name"] as? String, let tagDicts = dictionary["tags"] as? [[AnyHashable: Any]] else
		{
			return nil
		}
		
		var tags = [Tag]()
		
		for tagDict in tagDicts
		{
			if let tag = Tag(dictionary: tagDict)
			{
				tags.append(tag)
			}
		}
		
		self.init(identifier: identifier, name: name, tags: tags)
	}
}
