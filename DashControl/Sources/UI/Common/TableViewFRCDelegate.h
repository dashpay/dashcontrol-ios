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

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ConfigureCellBlock)(NSFetchedResultsController *fetchedResultsController, UITableViewCell *cell, NSIndexPath *indexPath);
typedef NSIndexPath *_Nonnull (^IndexPathTransformationBlock)(NSIndexPath *indexPath);

@class TableViewFRCDelegate;

@protocol TableViewFRCDelegateNotifier <NSObject>

@optional
- (void)tableViewFRCDelegateDidUpdate:(TableViewFRCDelegate *)frcDelegate;

@end

@interface TableViewFRCDelegate : NSObject <NSFetchedResultsControllerDelegate>

@property (nullable, weak, nonatomic) UITableView *tableView;
@property (nullable, copy, nonatomic) ConfigureCellBlock configureCellBlock;
@property (nullable, copy, nonatomic) IndexPathTransformationBlock transformationBlock;
@property (nullable, weak, nonatomic) id<TableViewFRCDelegateNotifier> notifier;

@end

NS_ASSUME_NONNULL_END
