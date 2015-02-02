//
//  AppDelegate.m
//  Fietsknelpunten
//
//  Created by Lieven Dekeyser on 02/02/15.
//  Copyright (c) 2015 Fietsknelpunten. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
	
	[self.window makeKeyAndVisible];
	
	return YES;
}


@end
