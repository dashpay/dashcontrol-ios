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

#import "QRScannerView.h"

#import <AVFoundation/AVFoundation.h>

#import "UIFont+DCStyle.h"
#import "QRScannerHintView.h"
#import "QRScannerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat const HINT_VIEW_PADDING = 40.0;

@interface QRScannerView ()

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) QRScannerHintView *hintView;
@property (strong, nonatomic) CAShapeLayer *qrCodeLayer;
@property (strong, nonatomic) CATextLayer *qrCodeTextLayer;

@end

@implementation QRScannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];

        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layer];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:previewLayer];
        _previewLayer = previewLayer;

        QRScannerHintView *hintView = [[QRScannerHintView alloc] initWithFrame:CGRectZero];
        hintView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:hintView];
        _hintView = hintView;

        UIView *overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        overlayView.translatesAutoresizingMaskIntoConstraints = NO;
        overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
        [self addSubview:overlayView];

        NSArray *toolbarItems;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                      target:self
                                                                                      action:@selector(cancelButtonAction:)];
        if (QRScannerViewModel.isTorchAvailable) {
            UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
            UIBarButtonItem *torchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flashIcon"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(torchButtonAction:)];
            toolbarItems = @[ cancelButton, flexItem, torchButton ];
        }
        else {
            toolbarItems = @[ cancelButton ];
        }

        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        toolbar.items = toolbarItems;
        toolbar.barStyle = UIBarStyleBlack;
        toolbar.translucent = YES;
        toolbar.tintColor = [UIColor whiteColor];
        [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
        [self addSubview:toolbar];

        // Layout

        if (@available(iOS 11.0, *)) {
            [hintView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:HINT_VIEW_PADDING].active = YES;
        }
        else {
            [hintView.topAnchor constraintEqualToAnchor:self.topAnchor constant:HINT_VIEW_PADDING].active = YES;
        }
        [NSLayoutConstraint activateConstraints:@[
            [hintView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:HINT_VIEW_PADDING],
            [hintView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-HINT_VIEW_PADDING],

            [overlayView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [overlayView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [overlayView.topAnchor constraintEqualToAnchor:toolbar.topAnchor],
            [overlayView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],

            [toolbar.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [toolbar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        ]];
        if (@available(iOS 11.0, *)) {
            [toolbar.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor].active = YES;
        }
        else {
            [toolbar.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        }

        // KVO

        [self mvvm_observe:@"viewModel.qrCodeObject" with:^(typeof(self) self, QRCodeObject * value) {
            [self handleQRCodeObject:value];
        }];

        [self mvvm_observe:@"viewModel.qrCodeObject.type" with:^(typeof(self) self, id value) {
            QRCodeObject *qrCodeObject = self.viewModel.qrCodeObject;
            [self updateQRCodeLayer:self.qrCodeLayer forObject:qrCodeObject];

            if (qrCodeObject.type == QRCodeObjectTypeValid) {
                // display successful scanning then return
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.delegate qrScannerView:self didScanString:qrCodeObject.metadataObject.stringValue];
                });
            }
        }];

        [self mvvm_observe:@"viewModel.hintText" with:^(typeof(self) self, NSString * value) {
            self.hintView.text = value;
            self.hintView.hidden = (self.hintView.text.length == 0);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.previewLayer.frame = self.bounds;
}

- (void)setViewModel:(QRScannerViewModel *)viewModel {
    _viewModel = viewModel;

    NSAssert([NSThread isMainThread], @"Current thread is other than main");
    self.previewLayer.session = _viewModel.captureSession;
}

#pragma mark Actions

- (void)cancelButtonAction:(id)sender {
    [self.delegate qrScannerViewDidCancel:self];
}

- (void)torchButtonAction:(id)sender {
    [self.viewModel switchTorch];
}

#pragma mark Private

- (void)handleQRCodeObject:(QRCodeObject *)qrCodeObject {
    [self.qrCodeLayer removeFromSuperlayer];

    if (!qrCodeObject) {
        return;
    }

    AVMetadataMachineReadableCodeObject *transformedObject =
        (AVMetadataMachineReadableCodeObject *)[self.previewLayer
            transformedMetadataObjectForMetadataObject:qrCodeObject.metadataObject];
    CGMutablePathRef path = CGPathCreateMutable();
    if (transformedObject.corners.count > 0) {
        for (NSDictionary *pointDictionary in transformedObject.corners) {
            CGPoint point;
            CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)pointDictionary, &point);

            if (pointDictionary == transformedObject.corners.firstObject) {
                CGPathMoveToPoint(path, NULL, point.x, point.y);
            }

            CGPathAddLineToPoint(path, NULL, point.x, point.y);
        }

        CGPathCloseSubpath(path);
    }

    CAShapeLayer *qrCodeLayer = [CAShapeLayer layer];
    qrCodeLayer.path = path;
    qrCodeLayer.lineJoin = kCALineJoinRound;
    qrCodeLayer.lineWidth = 4.0;

    [self updateQRCodeLayer:qrCodeLayer forObject:qrCodeObject];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.previewLayer addSublayer:qrCodeLayer];
    [CATransaction commit];
    self.qrCodeLayer = qrCodeLayer;
}

- (void)updateQRCodeLayer:(CAShapeLayer *)layer forObject:(QRCodeObject *)qrCodeObject {
    UIColor *color = nil;
    switch (qrCodeObject.type) {
        case QRCodeObjectTypeProcessing:
            color = [UIColor yellowColor];
            break;
        case QRCodeObjectTypeValid:
            color = [UIColor greenColor];
            break;
        case QRCodeObjectTypeInvalid:
            color = [UIColor redColor];
            break;
    }

    layer.strokeColor = [color colorWithAlphaComponent:0.7].CGColor;
    layer.fillColor = [color colorWithAlphaComponent:0.3].CGColor;

    [self.qrCodeTextLayer removeFromSuperlayer];

    if (!qrCodeObject.errorMessage) {
        return;
    }

    CGRect boundingBox = CGPathGetBoundingBox(layer.path);
    UIFont *font = [UIFont dc_montserratRegularFontOfSize:15.0];
    NSDictionary *attributes = @{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : [UIColor whiteColor],
    };
    CGRect textRect = [qrCodeObject.errorMessage boundingRectWithSize:boundingBox.size
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:attributes
                                                              context:nil];
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.frame = textRect;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.font = (__bridge CFTypeRef _Nullable)(font.fontName);
    textLayer.position = CGPointMake(CGRectGetMidX(boundingBox), CGRectGetMidY(boundingBox));
    textLayer.string = [[NSAttributedString alloc] initWithString:qrCodeObject.errorMessage
                                                       attributes:attributes];
    textLayer.wrapped = YES;
    [layer addSublayer:textLayer];
    self.qrCodeTextLayer = textLayer;
}

@end

NS_ASSUME_NONNULL_END
