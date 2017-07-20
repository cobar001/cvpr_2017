//
//  MapViewController.m
//  cvpr2
//
//  Created by Christopher Cobar on 7/11/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import "MapViewController.h"
#import "GyroData.h"
#import "AccelData.h"
#import "Interpolator.h"
#import "IMUMeasurement.h"
#import "FramePacket.h"

#import "AppDelegate.h"
#include "tong_cvpr_2017.h"
#include <vector>

using namespace std;

@interface MapViewController () {
    double _uptime;
    int _frameCount;
    double _gravity;
    
    int _imageFrameW;
    int _imageFrameH;
    
    UIView *_cameraView;
    UILabel *_introLabel;
    UILabel *_tapLabel;
    UILabel *_frameLabel;
    UITapGestureRecognizer *_touch;
    UIAlertController *_errorAlert;
    UIAlertController *_successAlert;
    
    double _collectionInterval;
    int _runInterpolator;
    Interpolator *_interpolator;
    NSOperationQueue *_interpolationQ;
    NSOperationQueue *_cameraQ;
    NSOperationQueue *_diskQ;
    CMMotionManager *_manager;
    
    AVCaptureSession *_videoCaptureSession;
    AVCaptureDevice *_captureDevice;
    AVCaptureDeviceInput *_captureInput;
    AVCaptureVideoDataOutput *_captureOutput;
    AVCaptureConnection *_captureConnection;
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    int _imuCollect;
    FramePacket *_lastFrame;
    NSMutableArray *_frames;
    NSMutableArray *_rawFrames;
    NSLock *_frameLock;
    NSLock *_imuLock;
    
    AppDelegate *_ADel;
    NSFileHandle *_imuHandle;
    
    vector<vector<double>> _imuData; // <t,wx,wy,wz,ax,ay,az>xN
    
}

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSError *error;
    _ADel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [[NSFileManager defaultManager] createDirectoryAtPath:_ADel.cvprPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create cvpr folder
    [[NSFileManager defaultManager] createFileAtPath:_ADel.imuFilePath contents:nil attributes:nil];
    
    _imuCollect = 0;
    _lastFrame = [[FramePacket alloc] init];
    _frameLock = [[NSLock alloc] init];
    _frames = [[NSMutableArray alloc] init];
    _imuLock = [[NSLock alloc] init];
    
    [self setupUIandGestures];
    
    // IMU
    _uptime = [[NSProcessInfo processInfo] systemUptime]; //get uptime
    _collectionInterval = 0.01;
    _gravity = 9.80781;
    _interpolationQ = [[NSOperationQueue alloc] init];
    _runInterpolator = 1;
    _interpolator = [[Interpolator alloc] init];
    NSLog(@"Interpolator intialized");
    _manager = [[CMMotionManager alloc] init];
    NSLog(@"CMManager intialized");
    _imuHandle = [NSFileHandle fileHandleForWritingAtPath:_ADel.imuFilePath];
    _diskQ = [[NSOperationQueue alloc] init];

    // Cam
    _frameCount = 0;
    _cameraQ = [[NSOperationQueue alloc] init];
    _imageFrameW = 640;
    _imageFrameH = 480;
    
    [self startCameraSession];
    [self setupPreviewLayer];
    
    NSLog(@"privates initialized");
    
    //start imu collection
    [self startGyroAccelCollection];
    
}

- (void)clearDocsPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:_ADel.cvprPath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:_ADel.cvprPath error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:_ADel.cvprPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create cvpr folder
        [[NSFileManager defaultManager] createFileAtPath:_ADel.imuFilePath contents:nil attributes:nil];
    }
}

- (void)setupUIandGestures {
    _touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchScreen:)];
    [self.view addGestureRecognizer:_touch];
    
    _cameraView = [[UIView alloc] init];
    [_cameraView setBackgroundColor:[UIColor blackColor]];
    _cameraView.translatesAutoresizingMaskIntoConstraints = false;
    
    [self.view addSubview:_cameraView];
    [_cameraView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = true;
    [_cameraView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = true;
    [_cameraView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = true;
    [_cameraView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = true;
    
    _introLabel = [[UILabel alloc] init];
    _introLabel.text = @"Tap the screen with two different views of the same area to triangulate.";
    _introLabel.textColor = [UIColor blackColor];
    _introLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:20];
    _introLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _introLabel.numberOfLines = 2;
    _introLabel.backgroundColor = [UIColor yellowColor];
    _introLabel.textAlignment = NSTextAlignmentCenter;
    _introLabel.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:_introLabel];
    [_introLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = true;
    [_introLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = true;
    [_introLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.7].active = true;
    [_introLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.3].active = true;
    
    _tapLabel = [[UILabel alloc] init];
    _tapLabel.text = @"1 Tap, move and tap again.";
    _tapLabel.textColor = [UIColor blackColor];
    _tapLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:20];
    _tapLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _tapLabel.numberOfLines = 1;
    _tapLabel.backgroundColor = [UIColor yellowColor];
    _tapLabel.textAlignment = NSTextAlignmentCenter;
    _tapLabel.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:_tapLabel];
    [_tapLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = true;
    [_tapLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.view.frame.size.height*0.08*-1].active = true;
    [_tapLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.4].active = true;
    [_tapLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.1].active = true;
    [_tapLabel setHidden:true];
    
    _frameLabel = [[UILabel alloc] init];
    _frameLabel.text = @"0 frames";
    _frameLabel.textColor = [UIColor whiteColor];
    _frameLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:12];
    _frameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _frameLabel.numberOfLines = 1;
    _frameLabel.backgroundColor = [UIColor clearColor];
    _frameLabel.textAlignment = NSTextAlignmentCenter;
    _frameLabel.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:_frameLabel];
    [_frameLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:8].active = true;
    [_frameLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-8].active = true;
    [_frameLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.15].active = true;
    [_frameLabel.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.1].active = true;

}

- (void)updateLabels {
    if (_frames.count == 0) {
        _tapLabel.text = @"1 Tap";
        [_introLabel setHidden:true];
        [_tapLabel setHidden:false];
    } else if (_frames.count == 1) {
        _tapLabel.text = @"Generating Map..";
    } else {
        [_tapLabel setHidden:true];
        [_introLabel setHidden:false];
    }
}

- (void)didTouchScreen:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"touch at x: %d y: %d", (int)location.x, (int)location.y);
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (_frames.count == 0) {
        [self updateLabels];
        [self performSelector:@selector(endIgnoringTouches) withObject:nil afterDelay:1.5];
        [self performSelector:@selector(startIMUCollect) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(saveFrame) withObject:nil afterDelay:1.0];
    } else if (_frames.count == 1) {
        [self updateLabels];
        [self performSelector:@selector(endIgnoringTouches) withObject:nil afterDelay:1.5];
        [self performSelector:@selector(saveFrame) withObject:nil afterDelay:0.5];
        [self performSelector:@selector(stopIMUCollectAndBuild) withObject:nil afterDelay:1.0];
    } else {
        [self updateLabels];
        [self endIgnoringTouches];
    }
}

- (void)endIgnoringTouches {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)startIMUCollect {
    NSLog(@"imu start");
    _imuCollect = 1;
}

- (void)stopIMUCollectAndBuild {
    NSLog(@"imu stop");
    _imuCollect = 0;
    std::string sDocString = std::string([_ADel.docsPath UTF8String]);
    _tEngine = new Tong_CVPR_2017(sDocString); // make new engine every attempt
    [self startMapBuild];
}

- (void)resetFrames {
    NSLog(@"frame imu reset");
    [_frames removeAllObjects];
    _imuData.clear();
    _frameLabel.text = @"0 frames";
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:_ADel.cvprPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create cvpr folder
    [[NSFileManager defaultManager] createFileAtPath:_ADel.imuFilePath contents:nil attributes:nil];
}

- (void)saveFrame {
    NSLog(@"new frame");
    [_frameLock lock];
    FramePacket *newframe = [[FramePacket alloc] init];
    newframe.timestamp = _lastFrame.timestamp;
    newframe.frame = (unsigned char*) malloc(_lastFrame.bufferSize);
    memcpy(newframe.frame, _lastFrame.frame, _lastFrame.bufferSize);
    newframe.frameWidth = _lastFrame.frameWidth;
    newframe.frameHeight = _lastFrame.frameHeight;
    newframe.imuFrame = _lastFrame.imuFrame;
    [_frames addObject:newframe];
    [_frameLock unlock];
    _frameLabel.text = [NSString stringWithFormat:@"%d frame(s)", (int)_frames.count];
}

- (int)getBestIMUIndex: (FramePacket *) fp {
    int imuIndex = 0;
    double time = fp.timestamp;
    double diff = 100.0;
    for (int i = 0; i < _imuData.size(); ++i) {
        double newDiff = fabs(_imuData[i][0] - time);
        if (newDiff < diff) {
            imuIndex = i;
            diff = newDiff;
        }
    }
    return imuIndex;
}

- (void)startMapBuild {
    NSLog(@"building map");
    NSLog(@"frame count: %d", (int)_frames.count);
    FramePacket *f1 = _frames[0];
    FramePacket *f2 = _frames[1];
    
    NSLog(@"Bframe1: %f ax: %f ay: %f az: %f",f1.imuFrame[0], f1.imuFrame[4], f1.imuFrame[5],f1.imuFrame[6]);
    NSLog(@"Bframe2: %f ax: %f ay: %f az: %f",f2.imuFrame[0], f2.imuFrame[4], f2.imuFrame[5],f2.imuFrame[6]);
    
//    f1.imuFrame = _imuData[[self getBestIMUIndex:f1]];
//    f2.imuFrame = _imuData[[self getBestIMUIndex:f2]];
    
    NSLog(@"f1 time: %f f2 time: %f", f1.timestamp, f2.timestamp);
    NSLog(@"Aframe1: %f ax: %f ay: %f az: %f",f1.imuFrame[0], f1.imuFrame[4], f1.imuFrame[5],f1.imuFrame[6]);
    NSLog(@"Aframe2: %f ax: %f ay: %f az: %f",f2.imuFrame[0], f2.imuFrame[4], f2.imuFrame[5],f2.imuFrame[6]);
    if (!_tEngine) {
        NSLog(@"tong engine not initialized");
        return;
    }
    bool status = _tEngine->constructMap(f1.frame, f2.frame, f1.timestamp, f2.timestamp, f1.imuFrame, f2.imuFrame, 480, 640);
    [_tapLabel setHidden:true];
    NSLog(@"%d", status);
    if (!status) {
        NSString *errorMessage = [NSString stringWithFormat:@"Could not extract plane. Landmark count: %d. Try again.", _tEngine->getLandmarkCount()];
        _errorAlert = [UIAlertController
         alertControllerWithTitle:@"Error"
         message:errorMessage
         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 
                                 [self clearDocsPath];
                                 [self updateLabels];
                                 [self resetFrames];
                                 [_errorAlert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self.navigationController popViewControllerAnimated:true];
                                     
                                 }];
        
        [_errorAlert addAction:ok];
        [_errorAlert addAction:cancel];
        
        [self presentViewController:_errorAlert animated:YES completion:nil];
    } else {
        _successAlert = [UIAlertController
                       alertControllerWithTitle:@"Success"
                       message:@"Plane Extracted. You may now begin AR."
                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 
                                 [self updateLabels];
                                 [self resetFrames];
                                 IndexViewController *vc = self.navigationController.viewControllers[0];
                                 vc.tEngine = _tEngine;
                                 [vc.startButton setEnabled:true];
                                 [self.navigationController popViewControllerAnimated:true];
                                 
                             }];
        [_successAlert addAction:ok];
        [self presentViewController:_successAlert animated:YES completion:nil];
    }
}

- (void)reset {
    [self resetFrames];
}

- (void)startGyroAccelCollection {
    
    if (_manager.gyroAvailable) {
        _manager.gyroUpdateInterval = _collectionInterval;
        [_manager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
    
            GyroData *gyroDataLog = [[GyroData alloc] init:gyroData.timestamp - _uptime
                                                         X:gyroData.rotationRate.x
                                                         Y:gyroData.rotationRate.y
                                                         Z:gyroData.rotationRate.z];
            [_interpolator GiveGyro:gyroDataLog];
        }];
    }
    
    if (_manager.accelerometerAvailable) {
        _manager.accelerometerUpdateInterval = _collectionInterval;
        [_manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            
            AccelData *accelDataLog = [[AccelData alloc] init:accelerometerData.timestamp - _uptime
                                                            X:accelerometerData.acceleration.x * _gravity
                                                            Y:accelerometerData.acceleration.y * _gravity
                                                            Z:accelerometerData.acceleration.z * _gravity];
            [_interpolator GiveAccel:accelDataLog];
        }];
    }
    
    [_interpolationQ addOperationWithBlock:^{
        
        while (_runInterpolator) {
            IMUMeasurement *imu = [_interpolator interpolate];
            
            if (imu != nil && _imuCollect) {
//                NSLog(@"%@", imu.toString);
                vector<double> imuDataPacket;
                imuDataPacket.push_back(imu.timeStamp);
                imuDataPacket.push_back(imu.gyroMeasurement.rotationX);
                imuDataPacket.push_back(imu.gyroMeasurement.rotationY);
                imuDataPacket.push_back(imu.gyroMeasurement.rotationZ);
                imuDataPacket.push_back(imu.accelMeasurement.accelerationX);
                imuDataPacket.push_back(imu.accelMeasurement.accelerationY);
                imuDataPacket.push_back(imu.accelMeasurement.accelerationZ);
                _imuData.push_back(imuDataPacket);
                NSLog(@"%@",imu.toString);
                
                NSData *textToFileIMU = [[NSString stringWithFormat:@"%@\n", imu.toString] dataUsingEncoding:NSUTF8StringEncoding];
                [_imuHandle writeData:textToFileIMU];
                //NSLog(@"%d",(int)_imuData.size());
            }
        }
    }];
}

- (void)startCameraSession {
    
    // Create the session
    _videoCaptureSession = [[AVCaptureSession alloc] init];
    [_videoCaptureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    // Find a suitable AVCaptureDevice and configure fps
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera
                                                                     mediaType:AVMediaTypeVideo
                                                                      position:AVCaptureDevicePositionBack];
    
    [self configureVideoInput:backCamera];
    
    [self configureVideoOutput: backCamera];
    
    //configure camera hardware
    [self cameraDeviceConfig:backCamera];
    
    // Start the session running to start the flow of data
    [_videoCaptureSession startRunning];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //process captured buffer data
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0); //lock buffer address for recording
        
    size_t bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    size_t bufferSize = bufferHeight * bytesPerRow;
        
    unsigned char *rowBase = (unsigned char *) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        
    //write organized buffer data to NSData for file
//    NSData *data = [NSData dataWithBytes:rowBase length:bufferSize];
    
    //release address
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
    //write to timestamp file
    double time = CMTimeGetSeconds(CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer));
    double differenceTime = time - _uptime;
    
    [_frameLock lock];
    _lastFrame.timestamp = differenceTime;
    _lastFrame.frame = rowBase;
    _lastFrame.frameWidth = 640;
    _lastFrame.frameHeight = 480;
    _lastFrame.bufferSize = bufferSize;
    [_imuLock lock];
    if (_imuData.size() > 0) {
        _lastFrame.imuFrame = _imuData.back();
    }
    [_imuLock unlock];
    [_frameLock unlock];
//    NSLog(@"last: %f %@", _lastFrame.timestamp, _lastFrame);
    
    _frameCount += 1;
    
}


- (void)cameraDeviceConfig: (AVCaptureDevice *)device {
    
    NSError *error;
    
    //disable autofocus
    if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
        [device lockForConfiguration:&error];
        device.focusMode = AVCaptureFocusModeLocked;
        [device unlockForConfiguration];
    }
    
    int fps = 30;
    [device lockForConfiguration:&error];
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, fps)];
    [device setActiveVideoMaxFrameDuration:CMTimeMake(1, fps)];
    [device unlockForConfiguration];
    
}


- (void)configureVideoOutput: (AVCaptureDevice *) device {
    
    // Create a VideoDataOutput and add it to the session
    _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoCaptureSession addOutput:_captureOutput];
    
    //to set up connection with proper output orientation
    _captureConnection = [_captureOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("bufferQ", NULL);
    [_captureOutput setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
    _captureOutput.videoSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                               forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    //discard frames if processor running behind
    [_captureOutput setAlwaysDiscardsLateVideoFrames:true];
    
}

- (void)configureVideoInput: (AVCaptureDevice *) device {
    
    NSError *error;
    
    // Create a device input with the device and add it to the session.
    AVCaptureInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!device) {
        // Handling the error appropriately.
        NSLog(@"%@", error);
    }
    
    [_videoCaptureSession addInput:deviceInput];
    
}

- (void)setupPreviewLayer {
    
    //setup display of image display to user
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_videoCaptureSession];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CALayer *root = [_cameraView layer];
    [root setMasksToBounds:true];
    CGRect frame = [self.view frame];
    
    [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    _previewLayer.frame = root.bounds;
    
    [_previewLayer setFrame:frame];
    [root insertSublayer:_previewLayer atIndex:0];
    
}


- (void)viewDidDisappear:(BOOL)animated {
    if (_manager.isGyroActive) {
        [_manager stopGyroUpdates];
        NSLog(@"gyro stopped");
    }
    if (_manager.isAccelerometerActive) {
        [_manager stopAccelerometerUpdates];
        NSLog(@"accel stopped");
    }
    if (_videoCaptureSession.isRunning) {
        [_videoCaptureSession stopRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
