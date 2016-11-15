//
//  AppDelegate.h
//  Kakuro_ver0
//
//  Created by Alexandr Nikanorov on 15.11.12.
//  Copyright (c) 2012 Alexandr Nikanorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    MenuViewController* mViewController;
    UINavigationController* navigationController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MenuViewController* mViewController;

@end
