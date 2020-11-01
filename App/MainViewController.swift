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
import Photos


class MainViewController: EditingViewController
{
	private let mapTypeSegmentedControl: UISegmentedControl
	private let mapView = MKMapView.newAutoLayout()
	private var firstAppearance = true
	
	fileprivate let geocoder = CLGeocoder()
	
	fileprivate var reportAnnotation: ReportAnnotation?
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
				reverseGeocodeReportLocation(selectWhenDone: true)
				isEditing = true
			}
			else
			{
				isEditing = false
			}
		}
	}	
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
	{
		let items = [
			NSLocalizedString("MAP_TYPE_MAP", value: "Map", comment: "Map type segmented control: Map item. Should be very short."),
			NSLocalizedString("MAP_TYPE_SATELLITE", value: "Satellite", comment: "Map type segmented control: Satellite item. Should be very short.")
		]
		mapTypeSegmentedControl = UISegmentedControl(items: items)
		mapTypeSegmentedControl.selectedSegmentIndex = 0
		
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		title = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		
		mapTypeSegmentedControl.addTarget(self, action: #selector(mapTypeSelected), for: .valueChanged)
		navigationItem.titleView = mapTypeSegmentedControl
		
		hidesBottomBarWhenPushed = false
		
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
	
	@objc private func mapTypeSelected()
	{
		mapView.mapType = mapTypeSegmentedControl.selectedSegmentIndex == 1 ? .hybrid : .standard
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
		
		let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
		
		#if DEBUG
		let showCamera = true
		#else
		let showCamera = cameraAvailable
		#endif // DEBUG
		
		if showCamera
		{
			let takePhoto = NSLocalizedString("TAKE_PHOTO", value: "Take Photo", comment: "Take Photo button in the action sheet displayed when a user wants to pick a photo. Should be short.")
			
			actionSheet.addAction(UIAlertAction(title: takePhoto, style: .default) { [weak self] (_) in
				self?.reportProblemUsingImagePicker(sourceType: cameraAvailable ? .camera : .photoLibrary)
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
	
	private func reportProblemUsingImagePicker(sourceType: UIImagePickerController.SourceType)
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
		reportAnnotation = annotation
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
	
	fileprivate func reverseGeocodeReportLocation(selectWhenDone: Bool)
	{
		guard let reportAnnotation = reportAnnotation else
		{
			return
		}
		
		let report = reportAnnotation.report
		let coordinate = report.coordinate
		report.countryCode = nil
		report.postalCode = nil
		report.jurisdiction = nil
		
		if selectWhenDone
		{
			mapView.deselectAnnotation(reportAnnotation, animated: false)
		}
		
		let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		geocoder.reverseGeocodeLocation(location)
		{
			[weak self] (placemarks, error) in
			
			reportAnnotation.placemark = placemarks?.first
			
			if selectWhenDone
			{
				self?.mapView.selectAnnotation(reportAnnotation, animated: false)
			}
		}
	}
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
	{
		guard let image = info[.originalImage] as? UIImage else
		{
			print("Should not happen: No image")
			dismiss(animated: true, completion: nil)
			return
		}
		
		dismiss(animated: true)
		{
			[weak self] in
			
			let continueWithoutLocation: ()->() =
			{
				self?.startNewReport(image: image, coordinate: nil)
			}
			
			guard let assetURL = info[.referenceURL] as? URL else
			{
				continueWithoutLocation()
				return
			}
			
			let continueWithLocation: ()->() = 
			{
				let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject
				let location = asset?.location
				self?.startNewReport(image: image, coordinate: location?.coordinate)
			}
			
			self?.checkPhotosAuthorization(denied: continueWithoutLocation, authorized: continueWithLocation)
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
	
	func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState)
	{
		if newState == .ending
		{
			reverseGeocodeReportLocation(selectWhenDone: annotationView.isSelected)
		}
	}
}



