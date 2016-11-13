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
	static let font = UIFont.systemFont(ofSize: 17.0)
	
	let textField = UITextField.newAutoLayout()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		textField.font = TextFieldCell.font
		
		contentView.addSubview(self.textField)
		
		textField.autoPinEdge(toSuperviewMargin: .leading, relation: .equal)
		textField.autoPinEdge(toSuperviewMargin: .trailing, relation: .equal)
		textField.autoAlignAxis(toSuperviewAxis: .horizontal)
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
