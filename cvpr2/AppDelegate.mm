//
//  AppDelegate.m
//  cvpr2
//
//  Created by Christopher Cobar on 7/11/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import "AppDelegate.h"
#include "tong_cvpr_2017.h"

@interface AppDelegate () {
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor purpleColor];
    _navigationController = [[UINavigationController alloc] init];
    _indexViewController = [[IndexViewController alloc] initWithNibName:NULL bundle:NULL];
    
    [_navigationController setViewControllers:[[NSArray alloc] initWithObjects:_indexViewController, nil]];
    
    _window.rootViewController = _navigationController;
    [_window makeKeyAndVisible];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    _docsPath = [paths objectAtIndex:0]; // Get documents folder
    _cvprPath = [_docsPath stringByAppendingPathComponent:@"/CVPR_demo_files"];
    _imuFilePath = [_cvprPath stringByAppendingString:@"/imu.txt"];
    _imagesFilePath = [_cvprPath stringByAppendingString:@"/Images"];
//    _image2FilePath = [_cvprPath stringByAppendingString:@"/image2.pgm"];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

