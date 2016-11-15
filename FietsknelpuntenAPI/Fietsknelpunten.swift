//
//  Fietsknelpunten.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 15/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import Foundation


public class Fietsknelpunten: NSObject
{
	public static let shared = Fietsknelpunten()
	
	private var tagGroups: [TagGroup]?
	
	public func getTags(refresh: Bool, completion: @escaping (Bool, [TagGroup]?, Error?)->())
	{
		if let tagGroups = tagGroups, !refresh
		{
			completion(true, tagGroups, nil)
		}
		else
		{
			API.shared?.getTags()
			{
				[weak self] (success, groups, error) in
				
				// Save for later
				if let groups = groups
				{
					self?.tagGroups = groups
				}
				
				// If the request failed but we already had groups, make sure we return those
				if let tagGroups = self?.tagGroups
				{
					completion(true, tagGroups, nil)
				}
				else
				{
					completion(success, groups, error)
				}
			}
		}
	}

}
