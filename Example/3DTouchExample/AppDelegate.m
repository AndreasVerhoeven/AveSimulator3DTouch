//
//  AppDelegate.m
//  3DTouchExample
//
//  Created by Andreas Verhoeven on 24-01-16.
//  Copyright © 2016 AveApps. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[MainViewController new]];
	[self.window makeKeyAndVisible];
	
	return YES;
}

@end
