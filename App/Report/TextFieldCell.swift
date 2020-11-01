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
	
	let label = UILabel.newAutoLayout()
	let textField = UITextField.newAutoLayout()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		textField.font = TextFieldCell.font
		label.font = TextFieldCell.font
		
		contentView.addSubview(label)
		contentView.addSubview(textField)
		
		label.autoPinEdge(toSuperviewMargin: .leading, relation: .equal)
		label.autoAlignAxis(toSuperviewAxis: .horizontal)
		
		textField.autoPinEdge(.leading, to: .trailing, of: label)
		textField.autoPinEdge(toSuperviewMargin: .trailing, relation: .equal)
		textField.autoAlignAxis(toSuperviewAxis: .horizontal)
		
		NSLayoutConstraint.autoSetPriority(.defaultHigh)
		{
			[weak label] in
			label?.autoSetContentHuggingPriority(for: .horizontal)
		}
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
