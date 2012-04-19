//
//  AppDelegate.m
//  ARPAV
//
//  Created by Andrea Mazzini on 17/04/12.
//  Copyright (c) 2012 CenTec. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsHelper.h"
#import "WeatherListViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];  	

	[[SettingsHelper sharedHelper] loadDefaults];
	[[SettingsHelper sharedHelper] updateWeatherOnlyOnline:NO];
	
	WeatherListViewController* viewController = [[WeatherListViewController alloc] initWithNibName:@"WeatherListView" bundle:nil];
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
	self.window.rootViewController = self.navigationController;
	[self.window makeKeyAndVisible];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[SettingsHelper sharedHelper] savePreferences];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[[SettingsHelper sharedHelper] loadDefaults];
	[[SettingsHelper sharedHelper] updateWeatherOnlyOnline:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
