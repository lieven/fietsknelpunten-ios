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
	var onDismiss: (()->())?
	
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
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
		
		API.shared?.getTags()
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
	}
	
	@objc func cancel()
	{
		self.onDismiss?()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
	
	override func viewWillDisappear(_ animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		self.view.endEditing(true)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return 3
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		switch indexPath.row
		{
			case 0:
				let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
				cell.textField.placeholder = NSLocalizedString("REPORT_PROBLEM_TITLE_PLACEHOLDER", value: "Title", comment: "Placeholder for the title field when reporting a new problem.")
				cell.textField.text = self.report.title
				return cell
			
			case 1:
				let reuseIdentifier = "TagsReuseIdentifier"
				
				let cell: UITableViewCell
				
				if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
				{
					cell = dequeuedCell
				}
				else
				{
					cell = UITableViewCell(style: .value1, reuseIdentifier: reuseIdentifier)
				}
				
				cell.textLabel?.text = NSLocalizedString("REPORT_PROBLEM_TAGS_PLACEHOLDER", value: "Type", comment: "Placeholder for the type/tags field when reporting a new problem")
				cell.detailTextLabel?.text = self.report.tagsString()
				return cell
			
			case 2:
				let cell = tableView.dequeueReusableCell(withIdentifier: TextViewCell.reuseIdentifier, for: indexPath) as! TextViewCell
				cell.textView.text = self.report.info
				cell.placeholderLabel.text = NSLocalizedString("REPORT_PROBLEM_INFO_PLACEHOLDER", value: "Description", comment: " Placeholder for the description field when reporting a new problem")
				cell.updatePlaceholderVisibility()
				cell.textView.delegate = self
				cell.minimumNumberOfLines = 3
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
			case 0:
				guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell else
				{
					return
				}
				cell.textField.becomeFirstResponder()
			
			case 1:
				guard let tagGroups = self.tagGroups else
				{
					return
				}
				
				self.navigationController?.pushViewController(ReportTagsViewController(report: self.report, tagGroups: tagGroups), animated: true)
			
			case 2:
				guard let cell = tableView.cellForRow(at: indexPath) as? TextViewCell else
				{
					return
				}
				cell.textView.becomeFirstResponder()
			
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
