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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AVCaptureSession;
@class AVMetadataMachineReadableCodeObject;

typedef NS_ENUM(NSUInteger, QRCodeObjectType) {
    QRCodeObjectTypeProcessing,
    QRCodeObjectTypeValid,
    QRCodeObjectTypeInvalid,
};

@interface QRCodeObject : NSObject

@property (readonly, strong, nonatomic) AVMetadataMachineReadableCodeObject *metadataObject;
@property (readonly, assign, nonatomic) QRCodeObjectType type;
@property (nullable, readonly, copy, nonatomic) NSString *errorMessage;

- (instancetype)init NS_UNAVAILABLE;

@end

//

@interface QRScannerViewModel : NSObject

@property (readonly, class, getter=isTorchAvailable) BOOL torchAvailable;
@property (readonly, strong, nonatomic) AVCaptureSession *captureSession;
@property (readonly, assign, nonatomic, getter=isCameraDeniedOrRestricted) BOOL cameraDeniedOrRestricted;
@property (nullable, readonly, strong, nonatomic) QRCodeObject *qrCodeObject;
@property (nullable, readonly, copy, nonatomic) NSString *hintText;

- (void)startPreview;
- (void)stopPreview;

- (void)switchTorch;

- (BOOL)validateQRCodeObjectValue:(NSString *_Nullable)stringValue error:(NSError *__autoreleasing _Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
