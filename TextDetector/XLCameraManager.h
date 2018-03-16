//
//  XLCameraManager.h
//  TextDetector
//
//  Created by xiaolin on 2018/3/15.
//  Copyright © 2018年 xiaolin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol XLCameraManagerDelegate <AVCaptureVideoDataOutputSampleBufferDelegate>
@optional
- (void)cameraManagerFailedWithError:(NSError *)error;
@end

@interface XLCameraManager : NSObject
@property (nonatomic, weak) id<XLCameraManagerDelegate> delegate;
- (instancetype) init __attribute__((unavailable("call method initWithCameraPosition:delegate: instead")));
- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition delegate:(id<XLCameraManagerDelegate>)delegate;

- (void)stopCamera;
- (void)startCamera;
- (void)switchCamera;
- (void)captureStillImageWithHandler:(void (^)(NSData *imageData))handler;
@end
