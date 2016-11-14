//
//  TintedButton.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 14/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit

class TintedButton: UIButton
{
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		
		updateBackgroundImage()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	override func tintColorDidChange()
	{
		super.tintColorDidChange()
		
		updateBackgroundImage()
	}
	
	private func updateBackgroundImage()
	{
		setBackgroundImage(tintedBackground(color: tintColor ?? UIColor.black), for: .normal)
	}
	
	private func tintedBackground(color: UIColor) -> UIImage?
	{
		let cornerRadius: CGFloat = 5.0
		let size = 1.0 + 2.0*cornerRadius
		let imageSize = CGSize(width: size, height: size)
		
		UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
		
		color.setFill()
		UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: imageSize.width, height: imageSize.height), cornerRadius: cornerRadius).fill()
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image?.stretchableImage(withLeftCapWidth: Int(cornerRadius), topCapHeight: Int(cornerRadius))
		
	}
}
