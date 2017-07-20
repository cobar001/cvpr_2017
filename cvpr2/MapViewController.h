//
//  MapViewController.h
//  cvpr2
//
//  Created by Christopher Cobar on 7/11/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "IndexViewController.h"
#include "tong_cvpr_2017.h"

@interface MapViewController : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property Tong_CVPR_2017 *tEngine;

@end
