//
//  UIImage+Util.h
//  TextDetector
//
//  Created by xiaolin on 2018/3/16.
//  Copyright © 2018年 xiaolin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (Util)

+ (UIImage *)xlCameraManager_imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (UIImage *)xlCameraManager_fixOrientation;
@end
