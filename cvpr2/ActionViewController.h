//
//  ActionViewController.h
//  cvpr
//
//  Created by Christopher Cobar on 7/9/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import "IndexViewController.h"
#import "MapViewController.h"
#include "tong_cvpr_2017.h"

@interface ActionViewController : GLKViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

/***
 * Directly manages a framebuffer object on your application’s behalf.
 */
@property GLKView *glkView;

@property EAGLContext *eaglContext;

@property GLKBaseEffect *glkBaseEff;

/***
 * An evaluation context for Core Image processing with Quartz 2D, Metal, or OpenGL*.
 * NOTE: may (probably will) be replaced with opencv.
 */
@property CIContext *ciContext;

@property CGRect videoPreviewBounds;

/***
 * Looks for single or multiple taps.
 */
@property UITapGestureRecognizer *touch;

/**
 * To coordinate the flow of data from AV input devices to outputs.
 */
@property AVCaptureSession *videoCaptureSession;

/**
 * A concrete sub-class of AVCaptureOutput you use to process
 * uncompressed frames from the video being captured, or to access
 * compressed frames.
 */
@property AVCaptureVideoDataOutput *captureOutput; //frame output

/**
 * Represents a connection between capture input and capture
 * output objects associated with a capture session.
 */
@property AVCaptureConnection *captureConnection; //connection

/**
 * Represents a physical capture device and the properties associated
 * with that device.
 */
@property AVCaptureDevice *captureDevice; //connection

@property Tong_CVPR_2017 *tEngine;


@end

