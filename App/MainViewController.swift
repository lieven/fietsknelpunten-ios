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


class MainViewController: UIViewController {
	
	private var mapView: MKMapView?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		self.title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
		
		setupToolbarItems()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupMapView()
	}
	
	private func setupToolbarItems() {
		
		self.toolbarItems = [
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(reportProblem)),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		]
	}
	
	private func setupMapView() {
		
		let mapView = MKMapView.newAutoLayout()
		self.mapView = mapView
		
		self.view.addSubview(mapView)
		
		mapView.autoPinEdgesToSuperviewEdges()
	}
	
	
	@objc private func reportProblem() {
		
		let reportViewController = ReportProblemViewController()
		reportViewController.modalPresentationStyle = .formSheet
		reportViewController.onDismiss = { [weak self] in
			self?.dismiss(animated: true, completion: nil)
		}
		
		self.present(UINavigationController(rootViewController: reportViewController), animated: true, completion: nil)
	}
}
