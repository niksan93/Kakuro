//
//  AppDelegate.m
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 15.11.12.
//  Copyright (c) 2012 Alexandr Nikanorov. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize mViewController;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    mViewController = [[MenuViewController alloc]init];
    //before IOS7
    //mViewController.wantsFullScreenLayout = YES;
    //after IOS7
    mViewController.edgesForExtendedLayout = YES;
    navigationController = [[UINavigationController alloc] initWithRootViewController:mViewController];
    [mViewController release];
    
    navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    //before IOS9
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //[mViewController prefersStatusBarHidden];
    
    return YES;
}

@end
