//
//  BlueToothConnect.h
//  cvpr2
//
//  Created by Christopher Cobar on 7/13/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BlueToothConnect : NSObject

@property CBCentralManager *_cbCentralManager;

@property dispatch_queue_t _blueToothQ;

@property NSMutableArray *peripherals;

- (instancetype)init:(UIViewController *) delegateVC;

- (void)scanForPeripherals;

- (void)stopScanForPeripherals;

@end
