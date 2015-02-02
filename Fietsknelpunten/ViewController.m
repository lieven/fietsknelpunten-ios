//
//  ViewController.m
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 02/02/15.
//  Copyright (c) 2015 Fietsknelpunten. All rights reserved.
//

#import "ViewController.h"

#import <MapKit/MapKit.h>


@interface ViewController ()

@property (nonatomic, strong) MKMapView * mapView;

@end

@implementation ViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.mapView];
}

@end
