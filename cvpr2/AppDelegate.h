//
//  AppDelegate.h
//  cvpr2
//
//  Created by Christopher Cobar on 7/11/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *indexViewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) NSString *docsPath;

@property (strong, nonatomic) NSString *cvprPath;

@property (strong, nonatomic) NSString *imuFilePath;

@property (strong, nonatomic) NSString *imagesFilePath;

@property (strong, nonatomic) NSString *image2FilePath;

@end

