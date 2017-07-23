//
//  IndexViewController.m
//  cvpr
//
//  Created by Christopher Cobar on 7/9/17.
//  Copyright © 2017 christophercobar. All rights reserved.
//

#import "IndexViewController.h"
#import "ActionViewController.h"
#import "MapViewController.h"
#import "AppDelegate.h"

@interface IndexViewController () {
    
    AppDelegate *_ADel;

}

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _ADel = _ADel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (!_tEngine) {
        std::string sDocString = std::string([_ADel.docsPath UTF8String]);
        _tEngine = new Tong_CVPR_2017(sDocString);
    }
    
    self.view.backgroundColor = [UIColor grayColor];
    
    [self setUpUI];
    [self.navigationController.navigationBar setHidden:true];
    
}

/**
 * User Interface View Setup
 */

- (void)setUpUI {
    
    // Label
    UILabel *indexLabel = [[UILabel alloc] init];
    [indexLabel setText:@"cvpr 2017"];
    indexLabel.textColor = [UIColor blackColor];
    indexLabel.translatesAutoresizingMaskIntoConstraints = false;
    indexLabel.textAlignment = NSTextAlignmentCenter;
    [indexLabel setFont:[UIFont systemFontOfSize:36]];
    
    [self.view addSubview:indexLabel];
    
    [indexLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = true;
    [indexLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.view.frame.size.height*0.2].active = true;
    [indexLabel.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.50].active = true;
    [indexLabel.heightAnchor constraintEqualToConstant:60].active = true;
    
    // Container View
    UIStackView *buttonStack = [[UIStackView alloc] init];
    buttonStack.backgroundColor = [UIColor purpleColor];
    buttonStack.alignment = UIStackViewAlignmentFill;
    buttonStack.distribution = UIStackViewDistributionFillEqually;
    buttonStack.axis = UILayoutConstraintAxisHorizontal;
    buttonStack.spacing = 50;
    buttonStack.translatesAutoresizingMaskIntoConstraints = false;
    
   // [self.view addSubview:buttonStack];
  //  [buttonStack.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = true;
   // [buttonStack.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.view.frame.size.height*-0.1].active = true;
   // [buttonStack.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.6].active = true;
   // [buttonStack.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.2].active = true;
    
    // Start button
    _startButton = [[UIButton alloc] init];
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(startButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    _startButton.translatesAutoresizingMaskIntoConstraints = false;
    _startButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _startButton.tintColor = [UIColor whiteColor];
    _startButton.backgroundColor = [UIColor purpleColor];
    if (!_tEngine) {
        [_startButton setEnabled:false];
    }
    
    // Map button
    UIButton *mapButton = [[UIButton alloc] init];
    [mapButton setTitle:@"Map" forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(mapButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    mapButton.translatesAutoresizingMaskIntoConstraints = false;
    mapButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    mapButton.tintColor = [UIColor whiteColor];
    mapButton.backgroundColor = [UIColor blueColor];
    
    [buttonStack addArrangedSubview:_startButton];
    [buttonStack addArrangedSubview:mapButton];
    
    UIButton *newStartButton = [[UIButton alloc] init];
    [newStartButton setTitle:@"Start" forState:UIControlStateNormal];
    [newStartButton addTarget:self action:@selector(newStartButtonPressed:)
        forControlEvents:UIControlEventTouchUpInside];
    newStartButton.translatesAutoresizingMaskIntoConstraints = false;
    newStartButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    newStartButton.tintColor = [UIColor whiteColor];
    newStartButton.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:newStartButton];
    [newStartButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = true;
    [newStartButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self.view.frame.size.height*-0.1].active = true;
    [newStartButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.6].active = true;
    [newStartButton.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.2].active = true;
    
}


/**
 * User Interface View Actions
 */
- (void)startButtonPressed:(UIButton *)button {
    ActionViewController *vc = [[ActionViewController alloc] initWithNibName:nil bundle:nil];
    if (!_tEngine->_isMapConstructed) {
        NSLog(@"Error: AR attempted without map.");
        return;
    }
    
    vc.tEngine = _tEngine;
    [self.navigationController pushViewController:vc animated:true];
}

- (void)newStartButtonPressed:(UIButton *)button {
    ActionViewController *vc = [[ActionViewController alloc] initWithNibName:nil bundle:nil];
    if (!_tEngine) {
        NSLog(@"Error: AR attempted without map.");
        return;
    }
    
    vc.tEngine = _tEngine;
    [self.navigationController pushViewController:vc animated:true];
}

- (void)mapButtonPressed:(UIButton *)button {
    MapViewController *vc = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:true];
}

/**
 * Hardware Protocal Methods
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    if (_tEngine) {
        NSLog(@"==== %d", (int)_tEngine->getLandmarkCount());
        NSLog(@"engine created: %d", (int)_tEngine->isEngineInitialized());
    }
}


@end
