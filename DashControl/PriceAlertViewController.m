//
//  PriceAlertViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 27/10/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "PriceAlertViewController.h"

#import "PriceAmountTableViewCell.h"
#import "AlertOverTableViewCell.h"

@interface PriceAlertViewController ()

@end

@implementation PriceAlertViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Price Alert", @"Price Alert Screen");
    
    if (self.priceAlertIdentifier) {
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePriceAlert:)];
        self.navigationItem.rightBarButtonItem = addBtn;
        self.isEditing = YES;
    }
    else {
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(savePriceAlert:)];
        self.navigationItem.rightBarButtonItem = addBtn;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)savePriceAlert:(UIBarButtonItem*)barButtonItem {
    
    if (self.isEditing) {
        //Edit delegate priceAlertDictionary
        
        for (NSMutableDictionary *objDic in self.delegate.priceAlertsArray) {
            if ([[objDic objectForKey:@"priceAlertIdentifier"] integerValue] == self.priceAlertIdentifier) {
                [objDic setObject:self.priceAmount forKey:@"priceAmount"];
                [objDic setObject:[NSNumber numberWithBool:self.isOver] forKey:@"isOver"];
            }
        }
        
    }
    else {
        NSMutableDictionary *objDic = [NSMutableDictionary new];
        [objDic setObject:self.priceAmount forKey:@"priceAmount"];
        [objDic setObject:[NSNumber numberWithBool:self.isOver] forKey:@"isOver"];
        [objDic setObject:[NSNumber numberWithInteger:[self nextIdentifies]] forKey:@"priceAlertIdentifier"];
        [self.delegate.priceAlertsArray addObject:objDic];
    }
    
    [self.delegate.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)nextIdentifies;
{
    static NSString* lastID = @"lastPriceAlertIdentifier";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSInteger identifier = [defaults integerForKey:lastID] + 1;
    [defaults setInteger:identifier forKey:lastID];
    [defaults synchronize];
    return identifier;
}

#pragma mark - Table view

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        PriceAmountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"priceAmountCell"];
        cell.labelPrice.text = NSLocalizedString(@"Price", @"Price Alert Screen");
        cell.textFieldInput.placeholder = NSLocalizedString(@"input", @"Price Alert Screen");
        if (self.priceAmount) {
            cell.textFieldInput.text = self.priceAmount.stringValue;
        }
        
        cell.textFieldInput.delegate = self;
        if (cell.textFieldInput.allTargets.count == 0) {
            [cell.textFieldInput addTarget:self action:@selector(updateLabelUsingContentsOfTextField:) forControlEvents:UIControlEventEditingChanged];
        }
        
        return cell;
    }
    if (indexPath.row == 1) {
        AlertOverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertOverCell"];
        cell.labelAlert.text = NSLocalizedString(@"Alert when Over", @"Price Alert Screen");
        cell.switchOver.on = self.isOver;
        
        if (cell.switchOver.allTargets.count == 0) {
            [cell.switchOver addTarget:self action:@selector(swithOverChanged:) forControlEvents:UIControlEventValueChanged];
        }
        
        return cell;
    }
    
    return nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)swithOverChanged:(UISwitch *)sender {
    self.isOver = sender.on;
}

- (void)updateLabelUsingContentsOfTextField:(UITextField*)sender {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *newPriceAmount = [numberFormatter numberFromString:sender.text];
    self.priceAmount = newPriceAmount;
}
@end
