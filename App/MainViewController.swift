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
	private var firstAppearance = true
	
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
	
	private var tagGroups: [TagGroup]?
	
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		self.title = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		self.hidesBottomBarWhenPushed = false
		
		updateToolbarItems()
		
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
		
		setupMapView()
	}
	
	private func setupMapView()
	{
		self.view.addSubview(mapView)
		
		mapView.delegate = self
		mapView.autoPinEdgesToSuperviewEdges()
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		
		if firstAppearance
		{
			showUserLocation()
			firstAppearance = false
		}
	}
	
	private func updateToolbarItems()
	{
		if self.isEditing
		{
			let report = NSLocalizedString("REPORT_PROBLEM_BUTTON", value: "Report", comment: "Report problem button. Should be short")
			
			self.toolbarItems = [
				UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelReportProblem)),
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
				UIBarButtonItem(title: report, style: .done, target: self, action: #selector(showReport))
			]
		}
		else
		{
			self.toolbarItems = [
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
				UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(reportProblem)),
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
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
	
	private func showUserLocation()
	{
		checkLocationAuthorization()
		{
			[weak self] in
			
			guard let strongSelf = self else
			{
				return
			}
			
			let mapView = strongSelf.mapView
			mapView.showsUserLocation = true
			mapView.userTrackingMode = .follow
			
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
	
	@objc private func reportProblem()
	{
		let newReportTitle = NSLocalizedString("NEW_REPORT_ACTIONSHEET_TITLE", value: "New Report", comment: "Title for the action sheet displayed when a user wants to create a new report. Should be very short")
		let actionSheet = UIAlertController(title: newReportTitle, message: nil, preferredStyle: .actionSheet)
		
		if UIImagePickerController.isSourceTypeAvailable(.camera)
		{
			let takePhoto = NSLocalizedString("TAKE_PHOTO", value: "Take Photo", comment: "Take Photo button in the action sheet displayed when a user wants to pick a photo. Should be short.")
			
			actionSheet.addAction(UIAlertAction(title: takePhoto, style: .default) { [weak self] (_) in
				self?.reportProblemUsingImagePicker(sourceType: .camera)
			})
		}
		
		let chooseFromLibrary = NSLocalizedString("CHOOSE_PHOTO_FROM_LIBRARY", value: "Photo from Library", comment: "Choose from Library button in the action sheet displayed when a user wants to pick a photo. Should be short.")
		actionSheet.addAction(UIAlertAction(title: chooseFromLibrary, style: .default) { [weak self] (_) in
			self?.reportProblemUsingImagePicker(sourceType: .photoLibrary)
		})
		
		
		let withoutPhoto = NSLocalizedString("REPORT_PROBLEM_WITHOUT_PHOTO", value: "Without Photo", comment: "Report a problem without photo")
		actionSheet.addAction(UIAlertAction(title: withoutPhoto, style: .default) { [weak self] (_) in
			self?.startNewReport(image: nil, coordinate: nil)
		})
		
		let cancel = NSLocalizedString("CANCEL", value: "Cancel", comment: "Cancel button. Should be very short")
		actionSheet.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
		
		present(actionSheet, animated: true, completion: nil)
	}
	
	private func reportProblemUsingImagePicker(sourceType: UIImagePickerControllerSourceType)
	{
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = sourceType
		imagePicker.mediaTypes = [kUTTypeImage as String]
		imagePicker.delegate = self
		
		present(imagePicker, animated: true, completion: nil)
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
		
		let annotation = ReportAnnotation(report: Report(coordinate: initialCoordinate, image: image))
		self.reportAnnotation = annotation
		mapView.selectAnnotation(annotation, animated: true)
	}
	
	@objc fileprivate func showReport()
	{
		guard let report = self.reportAnnotation?.report, let navigationController = self.navigationController else
		{
			return
		}
		
		let reportViewController = ReportProblemViewController(report: report)
		reportViewController.onDiscard = { [weak self] in self?.discardProblemReport() }
		navigationController.pushViewController(reportViewController, animated: true)
	}
	
	private func discardProblemReport()
	{
		self.reportAnnotation = nil
		
		let _ = self.navigationController?.popToRootViewController(animated: true)
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
			showReport()
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
		return NSLocalizedString("NEW_REPORT_PIN_SUBTITLE", value:"Drag to exact location", comment: "Subtitle for new report pins on the map. Should be short.")
	}
}
