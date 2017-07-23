//
//  ActionViewController.m
//  cvpr
//
//  Created by Christopher Cobar on 7/9/17.
//  Copyright  2017 christophercobar. All rights reserved.
//

#import "AppDelegate.h"
#import "ActionViewController.h"
#import "LinkedList.h"
#import "Node.h"
#import "cube.h"

using namespace std;

@interface ActionViewController () {
    
    bool _isComputing;
    UILabel *_problemLabel;
    int _frameCounter;
    
    GLKMatrix4 _centerPose;
    GLKMatrix4 _recentTranspose;
    GLKMatrix4 _transformPose;
    GLKMatrix4 _zeroMatrix;
    
    NSOperationQueue *_poseOPQ;
    unsigned char* _currentFrmae;
    
    AppDelegate *_ADel;
}

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"landmarks: %d", _tEngine->getLandmarkCount());
    std::vector<double> centerPoint = _tEngine->getPlaneCenterPoint();
    NSLog(@"center point: %f %f %f", centerPoint[0], centerPoint[1], centerPoint[2]);
    NSLog(@"plane height: %f", _tEngine->getPlaneHeightDist());
    
    NSError *error;
    _ADel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [[NSFileManager defaultManager] createDirectoryAtPath:_ADel.imagesFilePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create cvpr folder
    
    _poseOPQ = [[NSOperationQueue alloc] init];
    
    _transformPose = GLKMatrix4Identity;
    _centerPose = GLKMatrix4Identity;
    _centerPose = GLKMatrix4Translate(_centerPose, centerPoint[0], centerPoint[1], centerPoint[2]);
    _zeroMatrix = GLKMatrix4Make(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    _isComputing = true;
    _frameCounter = 0;
    
    // setup ui
    [self configureView];
    [self setupGestures];
    [self setUpUI];
    
    //setup camera and run
    
    if (!_videoCaptureSession) {
        [self setupCaptureSessionAndSelectDevice];
        [self setupSessionInput:_captureDevice withCaptureSession:_videoCaptureSession];
        [self setupSessionOutputAndConnection:_captureDevice withCaptureSession:_videoCaptureSession];
        [self configureDeviceHardware:_captureDevice];
    }
    NSLog(@"camera initialized.");
    [_videoCaptureSession startRunning];
    NSLog(@"stream started.");
    
}

/**
 * User Interface View Setup
 */

- (void)configureView {
    
    [self setPreferredFramesPerSecond:30];
    
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    CGRect mainScreen = [[UIScreen mainScreen] bounds];
    _glkView = (GLKView *) self.view;
    [_glkView setContext:_eaglContext];
    [_glkView setFrame:mainScreen];
    [_glkView setDrawableColorFormat:GLKViewDrawableColorFormatRGBA8888];
    
    [_glkView setOpaque:true];
    
    [_glkView bindDrawable];
    _videoPreviewBounds = CGRectZero;
    _videoPreviewBounds.size.width = _glkView.drawableWidth;
    _videoPreviewBounds.size.height = _glkView.drawableHeight;
    
    // OpenGL ES Settings
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CCW);
    
    
    [self createEffect];
    
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext];
    
    NSLog(@"View Initialized");
}

- (void)createEffect {
    _glkBaseEff = [[GLKBaseEffect alloc] init];
    
    // Texture
    NSDictionary* options = @{ GLKTextureLoaderOriginBottomLeft: @YES };
    NSError* error;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"cube.png" ofType:nil];
    GLKTextureInfo* texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    if(texture == nil)
        NSLog(@"Error loading file: %@", [error localizedDescription]);
    
    _glkBaseEff.texture2d0.name = texture.name;
    _glkBaseEff.texture2d0.enabled = true;
    
    // Light
//    _glkBaseEff.light0.enabled = GL_TRUE;
//    _glkBaseEff.light0.position = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    _glkBaseEff.lightingType = GLKLightingTypePerPixel;
}

- (void)setUpUI {
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setTitle:@"Stop" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(stopAndSegueBackToIndex:)
         forControlEvents:UIControlEventTouchUpInside];
    backButton.translatesAutoresizingMaskIntoConstraints = false;
    backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    backButton.tintColor = [UIColor whiteColor];
    backButton.backgroundColor = [UIColor purpleColor];
    backButton.layer.cornerRadius = 10;
    
    [self.glkView addSubview:backButton];
    
    [backButton.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-10.0].active = true;
    [backButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-10.0].active = true;
    [backButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.20].active = true;
    [backButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.20].active = true;
    
    _problemLabel = [[UILabel alloc] init];
}

/**
 * User Interface Actions Setup
 */

// Conform to UIGesturerecognizerDelegate for back swipe
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (void)stopAndSegueBackToIndex:(UIButton *)button {
    [self cleanUp]; // stop capturing
    IndexViewController *vc = self.navigationController.viewControllers[0];
//    vc.tEngine = nil;
    [vc.startButton setEnabled:false];
    [self.navigationController popViewControllerAnimated:true];
}

- (void)setupGestures {
    _touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchScreen:)];
    [self.glkView addGestureRecognizer:_touch];
}

- (void)didTouchScreen:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    NSLog(@"touch at x: %d y: %d", (int)location.x, (int)location.y);
}

/***
 * Camera Video Session Setup and Protocal Compliance
 */

- (void)setupCaptureSessionAndSelectDevice {
    _videoCaptureSession = [[AVCaptureSession alloc] init];
    [_videoCaptureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    _captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    
    NSLog(@"Session Setup.");
}

- (void)setupSessionInput:(AVCaptureDevice *)device
       withCaptureSession:(AVCaptureSession *)session {
    NSError *error;
    
    AVCaptureInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!device) {
        NSLog(@"%@", error);
    }
    
    [session addInput:deviceInput];
    
    NSLog(@"Input Setup.");
}

- (void)setupSessionOutputAndConnection:(AVCaptureDevice *)device
                     withCaptureSession:(AVCaptureSession *)session {
    _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput:_captureOutput];
    
    _captureConnection = [_captureOutput connectionWithMediaType:AVMediaTypeVideo];
    
    dispatch_queue_t dataQueue = dispatch_queue_create("frameQueue", NULL);
    [_captureOutput setSampleBufferDelegate:self queue:dataQueue];
    
    _captureOutput.videoSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [_captureOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    NSLog(@"Output Setup.");
}

- (void)configureDeviceHardware:(AVCaptureDevice *)device {
    NSError *error;
    
    // disable AF
    if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
        [device lockForConfiguration:&error];
        device.focusMode = AVCaptureFocusModeLocked;
        [device unlockForConfiguration];
    }
    
    // set device configurations
    int fps = 30;
    [device lockForConfiguration:&error];
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, fps)];
    [device setActiveVideoMaxFrameDuration:CMTimeMake(1, fps)];
    [device unlockForConfiguration];
    
    NSLog(@"Device Configured.");
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //process captured buffer data
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    size_t bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    
    // new
    _currentFrmae = (unsigned char *) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    // For Preview
    CIImage *outputFrame = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];
    
    CGRect frameExtent = outputFrame.extent;
    CGFloat sourceAspect = frameExtent.size.width/frameExtent.size.height;
    CGFloat previewAspect = _videoPreviewBounds.size.width/_videoPreviewBounds.size.height;
    
    // draw on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGRect drawRect = frameExtent;
        if (sourceAspect > previewAspect) {
            // use full height and width of image
            drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
            drawRect.size.width = drawRect.size.height * previewAspect;
        } else {
            // use full width and crop height
            drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
            drawRect.size.height = drawRect.size.width / previewAspect;
        }
        
        if (outputFrame) {
            [_ciContext drawImage:outputFrame inRect:_videoPreviewBounds fromRect:drawRect];
        }
        
    });
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    _frameCounter += 1;
    
}

- (void)cleanUp {
    _isComputing = false;
    [_videoCaptureSession stopRunning];
}

/***
 * GLK Protocal Methods
 */

// GLK View Delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //    glClear(GL_COLOR_BUFFER_BIT);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

//    if (NSStringFromGLKMatrix4(_transformPose) == NSStringFromGLKMatrix4(_zeroMatrix)) {
//        return;
//    }
    if ((_frameCounter % 5) == 0) {
        return;
    }
    
    [_glkBaseEff prepareToDraw];
    // Set matrices
    [self setMatrices];
    // Positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, cubePositions);
    // Draw Model
    glDrawArrays(GL_TRIANGLES, 0, cubeVertices); // vertices #
    // Texels
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, cubeTexels);
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, cubeNormals);
}

- (void)update {

//    _transformPose = _recentTranspose;
    if (_tEngine) {
        
        if (_currentFrmae && _isComputing) {
            NSDate *start = [NSDate date];
            //std::vector<double> updatedPose = _tEngine->computePose(_currentFrmae, 480, 640);
            std::vector<double> updatedPose = _tEngine->computePoseFromQR(_currentFrmae, 480, 640);
            NSDate *end = [NSDate date];
            NSTimeInterval time = [end timeIntervalSinceDate:start];
            NSLog(@"execution time: %f", time);
            if (updatedPose.size() != 0) {
                // update pose
                NSLog(@"Proposed pose R: [%f %f %f; %f %f %f; %f %f %f]", updatedPose[0], updatedPose[1], updatedPose[2],
                updatedPose[3], updatedPose[4], updatedPose[5],
                updatedPose[6], updatedPose[7], updatedPose[8]);
                NSLog(@"Proposed pose t: [%f %f %f]", updatedPose[9], updatedPose[10], updatedPose[11]);
        
                _transformPose = GLKMatrix4MakeAndTranspose(updatedPose[0], updatedPose[1], updatedPose[2], updatedPose[9], updatedPose[3], updatedPose[4], updatedPose[5], updatedPose[10], updatedPose[6], updatedPose[7], updatedPose[8], updatedPose[11], 0.0, 0.0, 0.0, 1.0);
                
            } else {
//                _transformPose = GLKMatrix4Make(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            }
        }
    }
    
}

/**
 * Hardware Protocal Methods
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMatrices {
    // Projection Matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 25.0f);
    _glkBaseEff.transform.projectionMatrix = projectionMatrix;
    
    // ModelView Matrix
//    NSLog(@"center: %f %f %f %f", _centerPose.m30, _centerPose.m31, _centerPose.m32, _centerPose.m33);
    GLKMatrix4 modelViewMatrix = _centerPose; // fixed to center currently
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.75, 0.75, 0.75);

    GLKMatrix4 rotX = GLKMatrix4Make(1, 0, 0, 0,
                                     0, -1, 0, 0,
                                     0, 0, -1, 0,
                                     0, 0, 0, 1);
    
    GLKMatrix3 rotation_t = GLKMatrix3Transpose(GLKMatrix4GetMatrix3(_transformPose));
    GLKMatrix4 transform = GLKMatrix4Make(rotation_t.m00, rotation_t.m01, rotation_t.m02, 0,
                                          rotation_t.m10, rotation_t.m11, rotation_t.m12, 0,
                                          rotation_t.m20, rotation_t.m21, rotation_t.m22, 0,
                                          _transformPose.m30, _transformPose.m31, _transformPose.m32, 1);
    
//    NSLog(@"pose est: %@", NSStringFromGLKMatrix4(_transformPose));
//    NSLog(@"LH: %@", NSStringFromGLKMatrix4(transform));
//    NSLog(@"RH: %@", NSStringFromGLKMatrix4(modelViewMatrix));
    
    modelViewMatrix = GLKMatrix4Multiply(transform, modelViewMatrix);
    modelViewMatrix = GLKMatrix4Multiply(rotX, modelViewMatrix);
    
//    NSLog(@"result: %@", NSStringFromGLKMatrix4(modelViewMatrix));
    
    _glkBaseEff.transform.modelviewMatrix = modelViewMatrix;
}

@end
