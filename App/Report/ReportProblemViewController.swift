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


class ReportProblemViewController: UIViewController {

	var onDismiss: (()->())?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		self.title = NSLocalizedString("REPORT_PROBLEM_TITLE", value: "Report Problem", comment: "Title for the Report Problem view. Should be short")
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.white
		
		API.shared?.getTags() { (success, groups, error) in
			
			if let groups = groups, success
			{
				for group in groups
				{
					print(group.name)
					
					for tag in group.tags
					{
						print("\t\(tag.name)")
					}
				}
			}
		}
	}
	
	@objc func cancel() {
		self.onDismiss?()
	}
}
