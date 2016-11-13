//
//  MainViewController.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 11/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit
import MapKit
import PureLayout
import FietsknelpuntenAPI
import CoreLocation


class MainViewController: EditingViewController
{
	private var mapView: MKMapView?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		self.title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
		
		updateToolbarItems()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		setupMapView()
	}
	
	private func setupMapView()
	{
		let mapView = MKMapView.newAutoLayout()
		self.mapView = mapView
		
		self.view.addSubview(mapView)
		
		mapView.autoPinEdgesToSuperviewEdges()
	}
	
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
	}
	
	private func updateToolbarItems()
	{
		if self.isEditing
		{
			let report = NSLocalizedString("REPORT_PROBLEM_BUTTON", value: "Report", comment: "Report problem button. Should be short")
			
			self.toolbarItems = [
				UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelReportProblem)),
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
				UIBarButtonItem(title: report, style: .done, target: self, action: #selector(reportProblem))
			]
		}
		else
		{
			let locationBarButtonItem = UIBarButtonItem(barButtonSystemItem: (mapView?.showsUserLocation ?? false) ? .stop : .play, target: self, action: #selector(toggleUserLocation))
			
			self.toolbarItems = [
				UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(reportProblemByChoosingPhoto)),
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
				locationBarButtonItem,
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
				UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(reportProblemByDroppingPin))
			]
		}
	}
	
	override var isEditing: Bool
	{
		didSet
		{
			updateToolbarItems()
		}
	}
	
	@objc private func toggleUserLocation()
	{
		checkLocationAuthorization()
		{
			[weak self] in
			
			guard let strongSelf = self, let mapView = strongSelf.mapView else
			{
				return
			}
			
			if mapView.showsUserLocation
			{
				mapView.showsUserLocation = false
			}
			else
			{
				mapView.showsUserLocation = true
				mapView.userTrackingMode = .follow
			}
			
			strongSelf.updateToolbarItems()
		}
	}
	
	
	
	@objc private func cancelReportProblem()
	{
		self.isEditing = false
	}
	
	@objc private func reportProblemByDroppingPin()
	{
		self.isEditing = true
	}
	
	@objc private func reportProblemByChoosingPhoto()
	{
		if UIImagePickerController.isSourceTypeAvailable(.camera)
		{
			let takePhoto = NSLocalizedString("TAKE_PHOTO", value: "Take Photo", comment: "Take Photo button in the action sheet displayed when a user wants to pick a photo. Should be short.")
			let chooseFromLibrary = NSLocalizedString("CHOOSE_PHOTO_FROM_LIBRARY", value: "Choose from Library", comment: "Choose from Library button in the action sheet displayed when a user wants to pick a photo. Should be short.")
			let cancel = NSLocalizedString("CANCEL", value: "Cancel", comment: "Cancel button. Should be very short")
			
			let camera = UIAlertAction(title: takePhoto, style: .default) { [weak self] (_) in
				self?.reportProblemUsingCamera()
			}
			
			let library = UIAlertAction(title: chooseFromLibrary, style: .default) { [weak self] (_) in
				self?.reportProblemWithExistingPhoto()
			}
			
			let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			actionSheet.addAction(camera)
			actionSheet.addAction(library)
			actionSheet.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
			
			present(actionSheet, animated: true, completion: nil)
		}
		else
		{
			reportProblemWithExistingPhoto()
		}
	}
	
	private func reportProblemUsingCamera()
	{
		
	}
	
	private func reportProblemWithExistingPhoto()
	{
		
	}
	
	@objc private func reportProblem()
	{
		let reportViewController = ReportProblemViewController()
		reportViewController.modalPresentationStyle = .formSheet
		reportViewController.onDismiss = { [weak self] in self?.dismissReportProblem() }
		
		self.present(UINavigationController(rootViewController: reportViewController), animated: true, completion: nil)
	}
	
	private func dismissReportProblem()
	{
		self.isEditing = false
		self.dismiss(animated: true, completion: nil)
	}
}

