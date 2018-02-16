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

#import "DCNewsPostEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@class DCPersistenceStack;
@class APINews;

typedef NS_ENUM(NSUInteger, NewsViewModelState) {
    NewsViewModelState_None,
    NewsViewModelState_Loading,
    NewsViewModelState_Success,
    NewsViewModelState_Failed,
};

@interface NewsViewModel : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(APINews) api;

@property (readonly, assign, nonatomic) NewsViewModelState state;
@property (readonly, strong, nonatomic) NSFetchedResultsController<DCNewsPostEntity *> *fetchedResultsController;

@property (readonly, assign, nonatomic) BOOL canLoadMore;

- (void)performFetch;

- (void)reload;
- (void)loadNextPage;

@end

NS_ASSUME_NONNULL_END
