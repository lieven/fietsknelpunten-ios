//
//  ReportProblemViewController.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 11/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit
import PureLayout
import FietsknelpuntenAPI


class ReportProblemViewController: UITableViewController
{
	var onDiscard: (()->())?
	
	var tagGroups: [TagGroup]?
	{
		didSet
		{
			self.tableView.reloadData()
		}
	}
	
	var report: Report
	
	init(report: Report)
	{
		self.report = report
		
		super.init(style: .grouped)
		
		self.title = NSLocalizedString("REPORT_PROBLEM_VIEW_TITLE", value: "Report Problem", comment: "Title for the Report Problem view. Should be short")
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		self.hidesBottomBarWhenPushed = true
		
		Fietsknelpunten.shared.getTags(refresh: false)
		{
			[weak self] (success, groups, error) in
			
			self?.tagGroups = groups
		}
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		guard let tableView = self.tableView else
		{
			return
		}
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 44.0
		tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseIdentifier)
		tableView.register(TextViewCell.self, forCellReuseIdentifier: TextViewCell.reuseIdentifier)
		tableView.sectionFooterHeight = UITableViewAutomaticDimension
		tableView.estimatedSectionFooterHeight = 100.0
	}
	
	@objc func cancel()
	{
		self.onDiscard?()
	}
	
	@objc func sendReport()
	{
		print("TODO: send")
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		self.titleFieldCell?.textField.becomeFirstResponder()
	}
	
	override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		self.view.endEditing(true)
	}
	
	let fieldsSection = 0
	
	let titleRowIndex = 0
	let tagRowIndex = 1
	let infoRowIndex = 2
	
	var titleFieldCell: TextFieldCell?
	{
		return tableView.cellForRow(at: IndexPath(row: titleRowIndex, section: fieldsSection)) as? TextFieldCell
	}
	
	var infoViewCell: TextViewCell?
	{
		return tableView.cellForRow(at: IndexPath(row: infoRowIndex, section: fieldsSection)) as? TextViewCell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 3
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
	{
		let footerView = UIView()
		
		let reportButton = TintedButton.newAutoLayout()
		reportButton.setTitle(NSLocalizedString("REPORT_PROBLEM_SEND_BUTTON", value: "Report Problem", comment: "Confirmation button when reporting a problem"), for: .normal)
		reportButton.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 20.0, bottom: 6.0, right: 20.0)
		reportButton.addTarget(self, action: #selector(sendReport), for: .touchUpInside)
		
		footerView.addSubview(reportButton)
		
		reportButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10.0)
		reportButton.autoPinEdge(toSuperviewMargin: .left)
		reportButton.autoPinEdge(toSuperviewMargin: .right)
		reportButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20.0)
		
		return footerView
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		switch indexPath.row
		{
			case titleRowIndex:
				let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
				cell.label.text = "\(NSLocalizedString("REPORT_PROBLEM_TITLE_PLACEHOLDER", value: "Title", comment: "Placeholder for the title field when reporting a new problem.")): "
				cell.label.textColor = TextViewCell.placeholderColor
				cell.textField.text = self.report.title
				cell.textField.delegate = self
				cell.textField.returnKeyType = .next
				return cell
			
			case tagRowIndex:
				let reuseIdentifier = "TagsReuseIdentifier"
				
				let cell: UITableViewCell
				
				if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
				{
					cell = dequeuedCell
				}
				else
				{
					cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
					cell.textLabel?.textColor = TextViewCell.placeholderColor
					cell.textLabel?.highlightedTextColor = UIColor.white
					cell.textLabel?.font = TextFieldCell.font
				}
				
				let label = NSLocalizedString("REPORT_PROBLEM_TAGS_PLACEHOLDER", value: "Type", comment: "Placeholder for the type/tags field when reporting a new problem")
				cell.textLabel?.text = "\(label): \(report.tagsString())"
				cell.accessoryType = tagGroups == nil ? .none : .disclosureIndicator
				
				return cell
			
			case infoRowIndex:
				let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.reuseIdentifier, for: indexPath) as! TextViewCell
				cell.textView.text = self.report.info
				cell.placeholderLabel.text = NSLocalizedString("REPORT_PROBLEM_INFO_PLACEHOLDER", value: "Description", comment: " Placeholder for the description field when reporting a new problem")
				cell.updatePlaceholderVisibility()
				cell.textView.delegate = self
				cell.minimumNumberOfLines = 1
				return cell
			
			default:
				fatalError("Index path out of bounds: \(indexPath)")
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		tableView.deselectRow(at: indexPath, animated: true)
		
		switch indexPath.row
		{
			case titleRowIndex:
				titleFieldCell?.textField.becomeFirstResponder()
			
			case tagRowIndex:
				guard let tagGroups = self.tagGroups else
				{
					return
				}
				
				self.navigationController?.pushViewController(ReportTagsViewController(report: self.report, tagGroups: tagGroups), animated: true)
			
			case infoRowIndex:
				infoViewCell?.textView.becomeFirstResponder()
			
			default:
				fatalError("Index path out of bounds: \(indexPath)")
		}
	}
}

extension ReportProblemViewController: UITextViewDelegate
{
	func textViewDidChange(_ textView: UITextView)
	{
		let currentOffset = tableView.contentOffset
		UIView.setAnimationsEnabled(false)
		self.tableView.beginUpdates()
		self.tableView.endUpdates()
		UIView.setAnimationsEnabled(true)
		self.tableView.setContentOffset(currentOffset, animated: false)
	}
}

extension ReportProblemViewController: UITextFieldDelegate
{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		infoViewCell?.textView.becomeFirstResponder()
		return false
	}
}
