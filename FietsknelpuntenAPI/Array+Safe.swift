//
//  Array+Safe.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import Foundation


extension Array
{
	public subscript (safe index: Int) -> Element?
	{
		return index >= 0 && index < self.count ? self[index] : nil
	}
}
