//
//  Fietsknelpunten.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 15/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import MapKit


public class Fietsknelpunten: NSObject
{
	public static let shared = Fietsknelpunten()
	
	private let userDefaults: UserDefaults
	
	public private(set) var boundingBox: MKCoordinateRegion?
	public private(set) var tagGroups: [TagGroup]?
	public private(set) var jurisdictions: [Jurisdiction]?
	
	override convenience init()
	{
		self.init(userDefaults: UserDefaults.standard)
	}
	
	public init(userDefaults: UserDefaults)
	{
		self.userDefaults = userDefaults
		super.init()
	}
	
	public func refreshTags(completion: @escaping (Bool, [TagGroup]?, Error?)->())
	{
		guard let api = API.shared else
		{
			completion(false, tagGroups, nil)
			return
		}
		
		api.getTags()
		{
			[weak self] (success, groups, error) in
			
			// Save for later
			if let groups = groups
			{
				self?.tagGroups = groups
			}
			
			completion(success, groups, error)
		}
	}
	
	public func refreshBoundingBox(completion: @escaping (Bool, MKCoordinateRegion?, Error?)->())
	{
		guard let api = API.shared else
		{
			completion(false, boundingBox, nil)
			return
		}
		
		api.getBoundingBox()
		{
			[weak self] (success, boundingBox, error) in
			
			if let boundingBox = boundingBox
			{
				self?.boundingBox = boundingBox
			}
			
			completion(success, boundingBox, error)
		}
	}
	
	public func refreshJurisdictions(completion: @escaping (Bool, [Jurisdiction]?, Error?)->())
	{
		guard let api = API.shared else
		{
			completion(false, nil, nil)
			return
		}
		
		api.getAllJurisdictions
		{
			[weak self] (success, jurisdictions, error) in
			
			if let jurisdictions = jurisdictions
			{
				self?.jurisdictions = jurisdictions
			}
			
			completion(success, jurisdictions, error)
		}
	}
}
