//
//  Tag.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 12/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit

public class Tag: NSObject
{
	public let identifier: String
	public let name: String
	public let info: String?
	
	public init(identifier: String, name: String, info: String?)
	{
		self.identifier = identifier
		self.name = name
		self.info = info
	}
}
