//
//  MainViewController.swift
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 11/11/16.
//  Copyright © 2016 Fietsknelpunten. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
	
	private var mapView: MKMapView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let mapView = MKMapView(frame: self.view.bounds)
		mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.view.addSubview(mapView)
		
		self.mapView = mapView
	}
}
