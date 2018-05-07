//
//  Created by Andrew Podkovyrin
//  Copyright © 2018 dashfoundation. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <AVFoundation/AVFoundation.h>

#import "QRScannerViewModel.h"

static NSTimeInterval const kResumeSearchTimeInterval = 1.0;

#pragma - QR Object

@interface QRCodeObject ()

@property (assign, nonatomic) QRCodeObjectType type;
@property (copy, nonatomic) NSString *errorMessage;

@end

@implementation QRCodeObject

- (instancetype)initWithMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObject {
    self = [super init];
    if (self) {
        _metadataObject = metadataObject;
    }
    return self;
}

- (void)setValid {
    self.errorMessage = nil;
    self.type = QRCodeObjectTypeValid;
}

- (void)setInvalidWithErrorMessage:(NSString *)errorMessage {
    self.errorMessage = errorMessage;
    self.type = QRCodeObjectTypeInvalid;
}

@end

#pragma mark - View Model

@interface QRScannerViewModel () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) dispatch_queue_t sessionQueue;
@property (strong, nonatomic) dispatch_queue_t metadataQueue;
@property (assign, nonatomic, getter=isCaptureSessionConfigured) BOOL captureSessionConfigured;
@property (assign, atomic) BOOL paused;
@property (strong, nonatomic) QRCodeObject *qrCodeObject;

@end

@implementation QRScannerViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return self;
}

+ (BOOL)isTorchAvailable {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return device.torchAvailable;
}

- (BOOL)isCameraDeniedOrRestricted {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted);
}

- (void)startPreview {
    void (^doStartPreview)(void) = ^{
#if !TARGET_OS_SIMULATOR
        [self setupCaptureSessionIfNeeded];
#endif /* TARGET_OS_SIMULATOR */

        dispatch_async(self.sessionQueue, ^{
            if (!self.captureSession.isRunning) {
                [self.captureSession startRunning];
            }
        });
    };

    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         if (granted) {
                                             dispatch_async(dispatch_get_main_queue(), doStartPreview);
                                         }
                                     }];
            break;
        }

        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            break;
        }

        case AVAuthorizationStatusAuthorized: {
            doStartPreview();
            break;
        }
    }
}

- (void)stopPreview {
    dispatch_async(self.sessionQueue, ^{
        if (self.captureSession.isRunning) {
            [self.captureSession stopRunning];
        }
    });
}

- (void)switchTorch {
    if (![[self class] isTorchAvailable]) {
        return;
    }

    if (!self.captureSession.isRunning) {
        return;
    }

    dispatch_async(self.sessionQueue, ^{
        NSError *error = nil;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

        if ([device lockForConfiguration:&error]) {
            device.torchMode = device.torchActive ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
            [device unlockForConfiguration];
        }
        else {
            DCDebugLog([self class], error);
        }
    });
}

- (BOOL)validateQRCodeObjectValue:(NSString *_Nullable)stringValue error:(NSError *__autoreleasing _Nullable *_Nullable)error {
    return YES;
}

#pragma mark Private

- (dispatch_queue_t)sessionQueue {
    if (!_sessionQueue) {
        _sessionQueue = dispatch_queue_create("QRScanerViewModel.CaptureSession.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}

- (dispatch_queue_t)metadataQueue {
    if (!_metadataQueue) {
        _metadataQueue = dispatch_queue_create("QRScanerViewModel.CaptureMetadataOutput.queue", DISPATCH_QUEUE_SERIAL);
    }
    return _metadataQueue;
}

- (void)setupCaptureSessionIfNeeded {
    if (self.isCaptureSessionConfigured) {
        return;
    }
    self.captureSessionConfigured = YES;

    dispatch_async(self.sessionQueue, ^{
        NSError *error = nil;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error) {
            DCDebugLog([self class], error);
        }
        if ([device lockForConfiguration:&error]) {
            if (device.isAutoFocusRangeRestrictionSupported) {
                device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
            }

            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }

            [device unlockForConfiguration];
        }
        else {
            DCDebugLog([self class], error);
        }

        [self.captureSession beginConfiguration];

        if (input && [self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
        }

        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        if ([self.captureSession canAddOutput:output]) {
            [self.captureSession addOutput:output];
        }
        [output setMetadataObjectsDelegate:self queue:self.metadataQueue];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            output.metadataObjectTypes = @[ AVMetadataObjectTypeQRCode ];
        }

        [self.captureSession commitConfiguration];
    });
}

- (void)pauseQRCodeSearch {
    self.paused = YES;
}

- (void)resumeQRCodeSearch {
    NSAssert([NSThread isMainThread], nil);
    self.paused = NO;
    self.qrCodeObject = nil;
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (self.paused) {
        return;
    }

    NSUInteger index = [metadataObjects indexOfObjectPassingTest:^BOOL(__kindof AVMetadataObject *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        return [obj.type isEqual:AVMetadataObjectTypeQRCode];
    }];
    if (index == NSNotFound) {
        return;
    }

    [self pauseQRCodeSearch];

    AVMetadataMachineReadableCodeObject *codeObject = metadataObjects[index];

    NSAssert(![NSThread isMainThread], nil);
    dispatch_sync(dispatch_get_main_queue(), ^{ // sync!
        self.qrCodeObject = [[QRCodeObject alloc] initWithMetadataObject:codeObject];

        NSError *error = nil;
        BOOL valid = [self validateQRCodeObjectValue:codeObject.stringValue error:&error];

        if (valid) {
            [self.qrCodeObject setValid];
        }
        else {
            NSString *errorMessage = nil;
            if (error) {
                errorMessage = error.userInfo[NSLocalizedDescriptionKey];
            }
            [self.qrCodeObject setInvalidWithErrorMessage:errorMessage];

            [self performSelector:@selector(resumeQRCodeSearch) withObject:nil afterDelay:kResumeSearchTimeInterval];
        }
    });
}

@end
