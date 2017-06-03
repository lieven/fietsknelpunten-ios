//
//  Jurisdiction.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 25/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import Foundation


public struct Jurisdiction
{
	public let identifier: String
	public let name: String
	public let countryCode: String
	public let postalCodes: [String]
	public let info: String?
	public let types: [String]?
}
