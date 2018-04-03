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

#import "FormTableViewController.h"

#import "UIColor+DCStyle.h"
#import "ButtonFormTableViewCell.h"
#import "SelectorFormTableViewCell.h"
#import "SwitcherFormTableViewCell.h"
#import "TextFieldFormTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const SELECTOR_CELL_ID = @"SelectorFormTableViewCell";
static NSString *const TEXTFIELD_CELL_ID = @"TextFieldFormTableViewCell";
static NSString *const SWITCHER_CELL_ID = @"SwitcherFormTableViewCell";
static NSString *const BUTTON_CELL_ID = @"ButtonFormTableViewCell";

@implementation FormTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = 51.0;
    self.tableView.backgroundColor = [UIColor dc_darkBlueColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
    self.tableView.separatorColor = [UIColor dc_darkBlueColor];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.contentInset = UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0);

    NSArray<NSString *> *cellIds = @[
        SELECTOR_CELL_ID,
        TEXTFIELD_CELL_ID,
        SWITCHER_CELL_ID,
        BUTTON_CELL_ID,
    ];
    for (NSString *cellId in cellIds) {
        UINib *nib = [UINib nibWithNibName:cellId bundle:nil];
        NSParameterAssert(nib);
        [self.tableView registerNib:nib forCellReuseIdentifier:cellId];
    }
}

- (void)setItems:(nullable NSArray<BaseFormCellModel *> *)items {
    _items = [items copy];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseFormCellModel *cellModel = self.items[indexPath.row];

    if ([cellModel isKindOfClass:SelectorFormCellModel.class]) {
        SelectorFormTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SELECTOR_CELL_ID forIndexPath:indexPath];
        cell.cellModel = (SelectorFormCellModel *)cellModel;
        return cell;
    }
    else if ([cellModel isKindOfClass:TextFieldFormCellModel.class]) {
        TextFieldFormTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TEXTFIELD_CELL_ID forIndexPath:indexPath];
        cell.cellModel = (TextFieldFormCellModel *)cellModel;
        return cell;
    }
    else if ([cellModel isKindOfClass:SwitcherFormCellModel.class]) {
        SwitcherFormTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SWITCHER_CELL_ID forIndexPath:indexPath];
        cell.cellModel = (SwitcherFormCellModel *)cellModel;
        return cell;
    }
    else {
        NSAssert([cellModel isKindOfClass:ButtonFormCellModel.class], @"unknown cell model");

        ButtonFormTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BUTTON_CELL_ID forIndexPath:indexPath];
        cell.cellModel = (ButtonFormCellModel *)cellModel;
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];

    NSParameterAssert(self.delegate);

    BaseFormCellModel *cellModel = self.items[indexPath.row];
    if ([cellModel isKindOfClass:SelectorFormCellModel.class]) {
        [self showValueSelectorForDetail:(SelectorFormCellModel *)cellModel];
    }
    else if ([cellModel isKindOfClass:ButtonFormCellModel.class]) {
        NSInteger index = [self.delegate formTableViewControllerIndexOfInvalidDetail:self];
        if (index == NSNotFound) {
            [self.delegate formTableViewControllerDone:self];
        }
        else {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
            shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            shakeAnimation.duration = 0.5;
            shakeAnimation.values = @[ @(-16), @(16), @(-8), @(8), @(-4), @(4), @(0) ];
            [cell.layer addAnimation:shakeAnimation forKey:@"ShakeAnimation"];
        }
    }
}

#pragma mark Private

- (void)showValueSelectorForDetail:(SelectorFormCellModel *)cellModel {
    NSArray<id<NamedObject>> *values = [self.delegate formTableViewController:self availableValuesForCellModel:cellModel];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:cellModel.title
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    for (id<NamedObject> value in values) {
        [alertController addAction:[UIAlertAction actionWithTitle:value.name
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              [self.delegate formTableViewController:self
                                                                                         selectValue:value
                                                                                        forCellModel:cellModel];
                                                          }]];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

@end

NS_ASSUME_NONNULL_END
