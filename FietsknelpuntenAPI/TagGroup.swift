//
//  TagGroup.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 12/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit

public class TagGroup: NSObject
{
	public let identifier: String
	public let name: String
	public let tags: [Tag]
	
	public init(identifier: String, name: String, tags: [Tag])
	{
		self.identifier = identifier
		self.name = name
		self.tags = tags
	}
	
}
