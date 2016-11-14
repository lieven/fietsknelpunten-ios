//
//  TextViewCell.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell
{
	static let reuseIdentifier = "TextViewCell"
	static let placeholderColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0)
	
	let textView = UITextView.newAutoLayout()
	let placeholderLabel = UILabel.newAutoLayout()
	var textViewHeightConstraint: NSLayoutConstraint?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let font = TextFieldCell.font
		
		textView.backgroundColor = UIColor.clear
		textView.isScrollEnabled = false
		textView.textContainer.lineFragmentPadding = 0.0
		textView.textContainerInset = .zero
		textView.font = font
		
		placeholderLabel.backgroundColor = UIColor.clear
		placeholderLabel.font = font
		placeholderLabel.textColor = TextViewCell.placeholderColor
		placeholderLabel.highlightedTextColor = UIColor.white
		placeholderLabel.isHidden = true
		
		contentView.addSubview(textView)
		contentView.addSubview(placeholderLabel)
		
		textView.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
		textView.autoPinEdge(toSuperviewMargin: .bottom, relation: .greaterThanOrEqual)
		updateHeightConstraint()
		
		placeholderLabel.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
		placeholderLabel.autoSetDimension(.height, toSize: font.lineHeight)
		
		NotificationCenter.default.addObserver(self, selector: #selector(textViewTextDidChange), name: .UITextViewTextDidChange, object: textView)
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit
	{
		NotificationCenter.default.removeObserver(self)
	}
	
	var minimumNumberOfLines: Int = 1
	{
		didSet
		{
			updateHeightConstraint()
		}
	}
	
	func updateHeightConstraint()
	{
		guard let font = textView.font, let _ = textView.superview else
		{
			return
		}
		
		let numLines = minimumNumberOfLines > 0 ? minimumNumberOfLines : 1
		let minimumHeight = ceil(font.lineHeight) * CGFloat(numLines)
		
		if let constraint = textViewHeightConstraint
		{
			constraint.constant = minimumHeight
		}
		else
		{
			self.textViewHeightConstraint = textView.autoSetDimension(.height, toSize: minimumHeight, relation: .greaterThanOrEqual)
		}
	}
	
	func textViewTextDidChange(_ notification: Notification)
	{
		updatePlaceholderVisibility()
	}
	
	func updatePlaceholderVisibility()
	{
		if let length = textView.text?.characters.count, length > 0
		{
			placeholderLabel.isHidden = true
		}
		else
		{
			placeholderLabel.isHidden = false
		}
	}
	
	override func prepareForReuse()
	{
		super.prepareForReuse()
		
		self.textView.text = nil
		//self.textView.placeholder = nil
	}	
}
