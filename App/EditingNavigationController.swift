//
//  EditingNavigationController.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 13/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit

private protocol EditingBar: class
{
	var editingStyle: Bool { get set }
	
	var window: UIWindow? { get }
	var barTintColor: UIColor? { get set }
	var tintColor: UIColor! { get set }
		
	func updateEditingTintColors()
}

private extension EditingBar
{
	func updateEditingTintColors()
	{
		let barTintColor: UIColor?
		let tintColor: UIColor?
		
		if self.editingStyle
		{
			barTintColor = self.window?.tintColor ?? UIColor.black
			tintColor = UIColor.white
		}
		else
		{
			barTintColor = nil
			tintColor = nil
		}
		
		self.barTintColor = barTintColor
		self.tintColor = tintColor
	}
}


class EditingNavigationController: UINavigationController
{
	private class NavigationBar: UINavigationBar, EditingBar
	{
		var editingStyle = false
		{
			didSet
			{
				updateStyle()
			}
		}
		
		override func tintColorDidChange()
		{
			super.tintColorDidChange()
			updateStyle()
		}
		
		func updateStyle()
		{
			updateEditingTintColors()
			
			let titleTextColor = self.tintColor ?? UIColor.black
			self.titleTextAttributes = [.foregroundColor: titleTextColor]
		}
	}
	
	private class Toolbar: UIToolbar, EditingBar
	{
		var editingStyle = false
		{
			didSet
			{
				updateEditingTintColors()
			}
		}
	}
	
	override init(rootViewController: UIViewController)
	{
		super.init(navigationBarClass: NavigationBar.self, toolbarClass: Toolbar.self)
		
		self.viewControllers = [rootViewController]
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	var editingStyle: Bool = false
	{
		didSet
		{
			(self.navigationBar as? NavigationBar)?.editingStyle = editingStyle
			(self.toolbar as? Toolbar)?.editingStyle = editingStyle
			setNeedsStatusBarAppearanceUpdate()
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle
	{
		return self.editingStyle ? .lightContent : .default
	}
	
	override var childForStatusBarStyle: UIViewController?
	{
		return nil
	}
}

extension UIViewController
{
	var editingNavigationController: EditingNavigationController?
	{
		return self.navigationController as? EditingNavigationController
	}
}

class EditingViewController: UIViewController
{
	override var isEditing: Bool
	{
		didSet
		{
			self.editingNavigationController?.editingStyle = isEditing
		}
	}
}

