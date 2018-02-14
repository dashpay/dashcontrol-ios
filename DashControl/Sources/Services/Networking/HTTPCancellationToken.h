//
//  HTTPCancellationToken.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//
//  Copyright (c) 2015-2018 Spotify AB.
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HTTPCancellationToken;

@protocol HTTPCancellationTokenDelegate <NSObject>

- (void)cancellationTokenDidCancel:(id<HTTPCancellationToken>)cancellationToken;

@end

@protocol HTTPCancellationToken <NSObject>

@property (nonatomic, assign, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, weak, readonly, nullable) id<HTTPCancellationTokenDelegate> delegate;
@property (nonatomic, strong, readonly, nullable) id objectToCancel;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
