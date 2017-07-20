//
//  BlueToothConnect.m
//  cvpr2
//
//  Created by Christopher Cobar on 7/13/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import "BlueToothConnect.h"

@implementation BlueToothConnect

- (instancetype)init: (UIViewController<CBCentralManagerDelegate> *) delegateVC {
    
    self = [super init];
    
    if (self) {
        
        self._blueToothQ = dispatch_queue_create("BTQ", NULL);
        self._cbCentralManager = [[CBCentralManager alloc] initWithDelegate:delegateVC queue:self._blueToothQ];
        
        
    } else {
        
        self = nil;
        
    }
    
    return self;
    
}

- (void)scanForPeripherals {
    [self._cbCentralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScanForPeripherals {
    [self._cbCentralManager stopScan];
}

@end
