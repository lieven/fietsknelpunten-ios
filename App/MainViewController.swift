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
import MobileCoreServices


class MainViewController: EditingViewController
{
	private let mapView = MKMapView.newAutoLayout()
	
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
		self.view.addSubview(mapView)
		
		mapView.delegate = self
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
			let locationBarButtonItem = UIBarButtonItem(barButtonSystemItem: mapView.showsUserLocation ? .stop : .play, target: self, action: #selector(toggleUserLocation))
			
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
			
			guard let strongSelf = self else
			{
				return
			}
			
			let mapView = strongSelf.mapView
			
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
		reportAnnotation = nil
	}
	
	@objc private func reportProblemByDroppingPin()
	{
		startNewReport(image: nil, coordinate: nil)
	}
	
	@objc private func reportProblemByChoosingPhoto()
	{
		if UIImagePickerController.isSourceTypeAvailable(.camera)
		{
			let takePhoto = NSLocalizedString("TAKE_PHOTO", value: "Take Photo", comment: "Take Photo button in the action sheet displayed when a user wants to pick a photo. Should be short.")
			let chooseFromLibrary = NSLocalizedString("CHOOSE_PHOTO_FROM_LIBRARY", value: "Choose from Library", comment: "Choose from Library button in the action sheet displayed when a user wants to pick a photo. Should be short.")
			let cancel = NSLocalizedString("CANCEL", value: "Cancel", comment: "Cancel button. Should be very short")
			
			let camera = UIAlertAction(title: takePhoto, style: .default) { [weak self] (_) in
				self?.reportProblemUsingImagePicker(sourceType: .camera)
			}
			
			let library = UIAlertAction(title: chooseFromLibrary, style: .default) { [weak self] (_) in
				self?.reportProblemUsingImagePicker(sourceType: .photoLibrary)
			}
			
			let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
			actionSheet.addAction(camera)
			actionSheet.addAction(library)
			actionSheet.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
			
			present(actionSheet, animated: true, completion: nil)
		}
		else
		{
			reportProblemUsingImagePicker(sourceType: .photoLibrary)
		}
	}
	
	private func reportProblemUsingImagePicker(sourceType: UIImagePickerControllerSourceType)
	{
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = sourceType
		imagePicker.mediaTypes = [kUTTypeImage as String]
		imagePicker.delegate = self
		
		present(imagePicker, animated: true, completion: nil)
	}
	
	@objc fileprivate func reportProblem()
	{
		guard let report = self.reportAnnotation?.report else
		{
			return
		}
		
		let reportViewController = ReportProblemViewController(report: report)
		reportViewController.modalPresentationStyle = .formSheet
		reportViewController.onDismiss = { [weak self] in self?.dismissReportProblem() }
		
		self.present(UINavigationController(rootViewController: reportViewController), animated: true, completion: nil)
	}
	
	private func dismissReportProblem()
	{
		reportAnnotation = nil
		
		dismiss(animated: true, completion: nil)
	}
	
	fileprivate func startNewReport(image: UIImage?, coordinate: CLLocationCoordinate2D?)
	{
		let initialCoordinate: CLLocationCoordinate2D
		
		if let coordinate = coordinate
		{
			initialCoordinate = coordinate
		}
		else if mapView.isUserLocationVisible
		{
			initialCoordinate = mapView.userLocation.coordinate
		}
		else
		{
			initialCoordinate = mapView.centerCoordinate
		}
		
		mapView.centerCoordinate = initialCoordinate
		
		reportAnnotation = ReportAnnotation(report: Report(coordinate: initialCoordinate, image: image))
	}
	
	private var reportAnnotation: ReportAnnotation?
	{
		didSet
		{
			if let oldAnnotation = oldValue
			{
				mapView.removeAnnotation(oldAnnotation)
			}
			
			if let newAnnotation = reportAnnotation
			{
				mapView.addAnnotation(newAnnotation)
				isEditing = true
			}
			else
			{
				isEditing = false
			}
		}
	}
	
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
	{
		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else
		{
			print("Should not happen: No image")
			dismiss(animated: true, completion: nil)
			return
		}
		
		dismiss(animated: true)
		{
			[weak self] in
			
			guard let assetURL = info[UIImagePickerControllerReferenceURL] as? URL else
			{
				self?.startNewReport(image: image, coordinate: nil)
				return
			}
			
			print("TODO: get location for image \(assetURL)")
			self?.startNewReport(image: image, coordinate: nil)
		}
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
	{
		dismiss(animated: true, completion: nil)
	}
}

extension MainViewController: MKMapViewDelegate
{
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
	{
		if let reportAnnotation = annotation as? ReportAnnotation
		{
			let reportPinReuseIdentifier = "ReportPin"
			
			let pin: MKPinAnnotationView
			
			if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reportPinReuseIdentifier) as? MKPinAnnotationView
			{
				pin = dequeuedAnnotationView
				pin.annotation = reportAnnotation
			}
			else
			{
				pin = MKPinAnnotationView(annotation: reportAnnotation, reuseIdentifier: reportPinReuseIdentifier)
				pin.pinTintColor = UIColor.red
				pin.isDraggable = true
				pin.animatesDrop = true
				pin.canShowCallout = true
				pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
				
			}
			
			if let image = reportAnnotation.report.images.first
			{
				let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
				imageView.image = image
				imageView.contentMode = .scaleAspectFill
				
				pin.leftCalloutAccessoryView = imageView
			}
			else
			{
				pin.leftCalloutAccessoryView = nil
			}
			
			return pin
		}
		
		return nil
	}
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
	{
		if control == view.rightCalloutAccessoryView
		{
			reportProblem()
		}
	}
}

private class ReportAnnotation: NSObject, MKAnnotation
{
	var report: Report
	
	init(report: Report)
	{
		self.report = report
		super.init()
	}
	
	var title: String?
	{
		return report.title ?? NSLocalizedString("NEW_REPORT_ANNOTATION_TITLE", value: "New Report", comment: "Title for a map annotation for a new report when no title has been chosen yet. Should be short.")
	}
	
	var coordinate: CLLocationCoordinate2D
	{
		get
		{
			return report.coordinate
		}
		set
		{
			report.coordinate = newValue
		}
	}
	
	var subtitle: String?
	{
		return report.tagsString()
	}
}
