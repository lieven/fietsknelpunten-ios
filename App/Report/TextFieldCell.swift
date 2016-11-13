//
//  TextFieldCell.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit
import PureLayout

class TextFieldCell: UITableViewCell
{
	static let reuseIdentifier = "TextFieldCell"
	
	let textField = UITextField.newAutoLayout()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.contentView.addSubview(self.textField)
		
		self.textField.autoPinEdge(toSuperviewMargin: .leading, relation: .equal)
		self.textField.autoPinEdge(toSuperviewMargin: .trailing, relation: .equal)
		self.textField.autoAlignAxis(toSuperviewAxis: .horizontal)
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse()
	{
		super.prepareForReuse()
		
		self.textField.text = nil
		self.textField.placeholder = nil
	}
}
