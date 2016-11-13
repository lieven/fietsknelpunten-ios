//
//  ReportTagsViewController.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit
import FietsknelpuntenAPI



class ReportTagsViewController: UITableViewController
{
	let tagGroups: [TagGroup]
	var report: Report
	
	init(report: Report, tagGroups: [TagGroup])
	{
		self.report = report
		self.tagGroups = tagGroups
		
		super.init(style: .grouped)
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return self.tagGroups.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.tagGroups[safe: section]?.tags.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		return self.tagGroups[safe: section]?.name
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let reuseIdentifier = "TagsReuseIdentifier"
				
		let cell: UITableViewCell
		
		if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
		{
			cell = dequeuedCell
		}
		else
		{
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
		}
		
		if let tag = self.tagGroups[safe: indexPath.section]?.tags[safe: indexPath.row]
		{
			cell.textLabel?.text = tag.name
			cell.detailTextLabel?.text = tag.info
			cell.accessoryType = self.report.tags.contains(tag) ? .checkmark : .none
		}
		else
		{
			cell.textLabel?.text = ""
			cell.detailTextLabel?.text = ""
			cell.accessoryType = .none
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		if let tag = tagGroups[safe: indexPath.section]?.tags[safe: indexPath.row]
		{
			if let index = self.report.tags.index(of: tag)
			{
				self.report.tags.remove(at: index)
			}
			else
			{
				self.report.tags.append(tag)
			}
			
			tableView.reloadRows(at: [indexPath], with: .automatic)
		}
		else
		{
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
}
