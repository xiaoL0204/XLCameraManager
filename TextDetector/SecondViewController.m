//
//  SecondViewController.m
//  TextDetector
//
//  Created by xiaolin on 2018/3/16.
//  Copyright © 2018年 xiaolin. All rights reserved.
//

#import "SecondViewController.h"
#import "XLCameraManager.h"
#import "UIImage+Util.h"

@interface SecondViewController () <XLCameraManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, strong) XLCameraManager *cameraManager;
@property (nonatomic,assign) BOOL bStart;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraManager = [[XLCameraManager alloc] initWithCameraPosition:AVCaptureDevicePositionBack delegate:self];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [self.cameraManager startCamera];
    self.bStart = YES;
    [self updateStartButtonUI:self.bStart];
}

#pragma mark - 开始/停止
- (IBAction)onStartButtonClicked:(UIButton *)sender {
    if (self.bStart) {
        [self.cameraManager stopCamera];
    } else {
        [self.cameraManager startCamera];
    }
    self.bStart = !self.bStart;
    [self updateStartButtonUI:self.bStart];
}

#pragma mark - 切换摄像头
- (IBAction)onSwitchCameraButtonClicked:(UIButton *)sender {
    [self.cameraManager switchCamera];
}
#pragma mark - 拍照
- (IBAction)onCaptureButtonClicked:(UIButton *)sender {
    [self.cameraManager captureStillImageWithHandler:^(NSData *imageData) {
        [self.snapshotImageView setImage:[UIImage imageWithData:imageData]];
    }];
}
#pragma mark -

- (void)updateStartButtonUI:(BOOL)bStart{
    self.bStart = bStart;
    [self.startButton setTitle:bStart ? @"停止" : @"开始" forState:UIControlStateNormal];
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    @autoreleasepool {
        UIImage *image = [[UIImage xlCameraManager_imageFromSampleBuffer:sampleBuffer] xlCameraManager_fixOrientation];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self.imageView setImage:image];
            
            
        });
        
    }
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
