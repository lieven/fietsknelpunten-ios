//
//  ReportJurisdictionViewController.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 25/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit
import FietsknelpuntenAPI



class ReportJurisdictionViewController: UITableViewController
{
	var report: Report
	
	let jurisdictions: [Jurisdiction]
	let possibleTypes: [String]
	
	
	var selectedType: String?
	{
		didSet
		{
			filteredJurisdictions = filterJurisdictions()
		}
	}
	
	var filteredJurisdictions: [Jurisdiction]
	{
		didSet
		{
			let indexSet: IndexSet = [jurisdictionsSection, typesSection]
			tableView.reloadSections(indexSet, with: .automatic)
		}
	}
	
	
	
	private func filterJurisdictions() -> [Jurisdiction]
	{
		guard let selectedType = selectedType else
		{
			return jurisdictions
		}
		
		if selectedType.count > 0
		{
			return jurisdictions.filter { $0.types?.contains(selectedType) ?? false }
		}
		else
		{
			return jurisdictions.filter { ($0.types?.count ?? 0) == 0 }
		}
	}
	
			
	init(report: Report, jurisdictions: [Jurisdiction])
	{
		self.report = report
		self.jurisdictions = jurisdictions
		
		var types = Set< String >()
		jurisdictions.forEach { if let jurisdictionTypes = $0.types { types.formUnion(jurisdictionTypes) } }
		
		var typesArray = [String]()
		typesArray = [String]()
		typesArray.append(contentsOf: types)
		typesArray.append("")
		possibleTypes = typesArray
		
		filteredJurisdictions = jurisdictions
		
		super.init(style: .grouped)
		
		self.title = NSLocalizedString("REPORT_SELECT_JURISDICTION_TITLE", value: "Select Jurisdiction", comment: "Title for the jurisdiction view. Should be short.")
		self.hidesBottomBarWhenPushed = true
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	private let jurisdictionsSection = 0
	private let typesSection = 1
	
	private let numSections = 2
	
	override func numberOfSections(in tableView: UITableView) -> Int
	{
		return numSections
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch section
		{
			case typesSection:
				return possibleTypes.count
			
			case jurisdictionsSection:
				return filteredJurisdictions.count
			
			default:
				fatalError("unknown section \(section)")
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		if section == typesSection
		{
			return "Filter op wegtype:"
		}
		else
		{
			return nil
		}
	}

	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		switch indexPath.section
		{
			case typesSection:
				let reuseIdentifier = "TypeReuseIdentifier"
				let cell: UITableViewCell
		
				if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
				{
					cell = dequeuedCell
				}
				else
				{
					cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
				}
				
				let row = indexPath.row
				let typeString = possibleTypes[row]
				
				cell.textLabel?.text = typeString == "" ? "Andere" : typeString.capitalized
				cell.accessoryType = selectedType == typeString ? .checkmark : .none
				
				return cell
			
			case jurisdictionsSection:
				let reuseIdentifier = "JurisdictionReuseIdentifier"
				
				let cell: UITableViewCell
				
				if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
				{
					cell = dequeuedCell
				}
				else
				{
					cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
				}
				
				let jurisdiction = filteredJurisdictions[indexPath.row]
				
				cell.textLabel?.text = jurisdiction.name
				cell.detailTextLabel?.text = jurisdiction.info
				
				cell.accessoryType = report.jurisdiction?.identifier == jurisdiction.identifier ? .checkmark : .none
				
				return cell
			
			default:
				fatalError("unknown index path \(indexPath)")
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		switch indexPath.section
		{
			case typesSection:
				selectedType = possibleTypes[indexPath.row]
			
			case jurisdictionsSection:
				let jurisdiction = filteredJurisdictions[safe: indexPath.row]
				report.jurisdiction = jurisdiction
				tableView.reloadRows(at: [indexPath], with: .automatic)
			
			default:
				return
		}
	}
}
