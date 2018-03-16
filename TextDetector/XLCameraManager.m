//
//  XLCameraManager.m
//  TextDetector
//
//  Created by xiaolin on 2018/3/15.
//  Copyright © 2018年 xiaolin. All rights reserved.
//

#import "XLCameraManager.h"

@interface XLCameraManager() <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;

@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@end

@implementation XLCameraManager

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition delegate:(id<XLCameraManagerDelegate>)delegate{
    self = [super init];
    if (self) {
        self.cameraPosition = cameraPosition;
        self.delegate = delegate;
        [self configureCamera];
    }
    return self;
}


- (void)configureCamera{
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    [self callSessionQueue:^{
        [self configureDeviceInputWithCameraPosition:self.cameraPosition];
        [self configureVideoDataOutput];
        [self configureStillImageOutput];
    }];
}


- (void)configureDeviceInputWithCameraPosition:(AVCaptureDevicePosition)position{
    AVCaptureDevice *device = [self cameraDeviceWithPosition:position];
    NSError *error = nil;
    self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraManagerFailedWithError:)]) {
            [self.delegate cameraManagerFailedWithError:error];
        }
        return;
    }
    
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
}
- (void)configureVideoDataOutput{
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    [output setSampleBufferDelegate:self queue:dispatch_queue_create("xl.camera.manager", DISPATCH_QUEUE_SERIAL)];
    
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
}

- (void)configureStillImageOutput{
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG,
                                         AVVideoQualityKey : @(0.9)};
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
}


- (void)startCamera{
    if (!self.session) {
        return;
    }
    
    [self callSessionQueue:^{
        [self.session startRunning];
    }];
}
- (void)stopCamera{
    if (!self.session) {
        return;
    }
    
    [self callSessionQueue:^{
        [self.session stopRunning];
    }];
}
- (void)switchCamera{
    switch (self.cameraPosition) {
        case AVCaptureDevicePositionUnspecified:
        case AVCaptureDevicePositionBack:
            self.cameraPosition = AVCaptureDevicePositionFront;
            break;
        case AVCaptureDevicePositionFront:
            self.cameraPosition = AVCaptureDevicePositionBack;
            break;
        default:
            break;
    }
    
    
    [self.session removeInput:self.deviceInput];
    [self configureDeviceInputWithCameraPosition:self.cameraPosition];
    
}

- (void)captureStillImageWithHandler:(void (^)(NSData *imageData))handler {
    [self callSessionQueue:^{
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            if (error == nil) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                handler(imageData);
            } else {
                handler(nil);
            }
        }];
    }];
}

- (AVCaptureDevice *)cameraDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray *avaiableCameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in avaiableCameras) {
        if (camera.position == position) {
            return camera;
        }
    }
    return nil;
}

- (void)callSessionQueue:(void(^)(void))action {
    if (!self.sessionQueue) {
        return;
    }
    dispatch_async(self.sessionQueue, ^{
        action();
    });
}
- (dispatch_queue_t)sessionQueue{
    if (!_sessionQueue) {
        _sessionQueue = dispatch_queue_create("xl.camera.session", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (self.delegate && [self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:)]) {
        [self.delegate captureOutput:output didOutputSampleBuffer:sampleBuffer fromConnection:connection];
    }
}

@end
