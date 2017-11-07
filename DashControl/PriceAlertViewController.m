//
//  PriceAlertViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 27/10/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "PriceAlertViewController.h"
#import "PriceAmountTableViewCell.h"
#import "TriggerTypeTableViewCell.h"
#import "AddTriggerTableViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DCBackendManager.h"

@interface PriceAlertViewController ()

@property(nonatomic,strong) PriceAmountTableViewCell * priceAmountTableViewCell;
@property(nonatomic,strong) TriggerTypeTableViewCell * triggerTypeTableViewCell;
@property(nonatomic,strong) AddTriggerTableViewCell * addTriggerTableViewCell;
@property(nonatomic,assign) DCTriggerType triggerType;

@end

@implementation PriceAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Price Alert", @"Price Alert Screen");
    
    self.priceAmountTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"PriceValueCell"];
    self.priceAmountTableViewCell.mainLabel.text = NSLocalizedString(@"Price", @"Price Alert Screen");
    self.priceAmountTableViewCell.priceTextField.placeholder = NSLocalizedString(@"required", @"Price Alert Screen");
    self.priceAmountTableViewCell.priceTextField.delegate = self;
    
    self.triggerTypeTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"TriggerTypeCell"];
    self.triggerTypeTableViewCell.mainLabel.text = NSLocalizedString(@"Alert type", @"Price Alert Screen");
    self.triggerTypeTableViewCell.typeLabel.text = [self textForTriggerType:DCTriggerAbove];
    
    self.addTriggerTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"AddTriggerCell"];
    self.triggerType = DCTriggerAbove;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!section) {
        return 2;
    } else {
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!indexPath.section) {
        switch (indexPath.row) {
            case 0:
            {
                return self.priceAmountTableViewCell;
            }
            case 1:
            {
                return self.triggerTypeTableViewCell;
            }
        }
    } else {
        return self.addTriggerTableViewCell;
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    if (indexPath.section) {
        if (self.priceAmountTableViewCell.priceTextField.text && ![self.priceAmountTableViewCell.priceTextField.text isEqualToString:@""]) {
            [self addTrigger:self];
        } else {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"You must input a value",@"Price Alert Screen") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok",@"ok") style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:TRUE completion:nil];
        }
    } else if (indexPath.row == 1) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"trigger type",@"Price Alert Screen") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSInteger i = 0;i<DCTriggerBelow + 1;i++) {
            NSString * triggerText = [self textForTriggerType:i];
            [alertController addAction:[UIAlertAction actionWithTitle:triggerText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.triggerType = i;
                self.triggerTypeTableViewCell.typeLabel.text = triggerText;
            }]];
        }
        [self presentViewController:alertController animated:TRUE completion:^{
            
        }];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.section) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:[self textForTriggerType:self.triggerType] message:[self explanationForTriggerType:self.triggerType] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok",@"ok") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:TRUE completion:^{
            
        }];
    }
}

-(NSString*)textForTriggerType:(DCTriggerType)triggerType {
    switch (triggerType) {
        case DCTriggerAbove:
            return NSLocalizedString(@"Alert when over",@"Price Alert Screen");
            break;
        case DCTriggerBelow:
            return NSLocalizedString(@"Alert when under",@"Price Alert Screen");
            break;
        case DCTriggerAboveFor:
            return NSLocalizedString(@"Alert when over for a time period",@"Price Alert Screen");
            break;
        case DCTriggerBelowFor:
            return NSLocalizedString(@"Alert when under for a time period",@"Price Alert Screen");
            break;
        case DCTriggerSpikeUp:
            return NSLocalizedString(@"Alert when price rises quickly",@"Price Alert Screen");
            break;
        case DCTriggerSpikeDown:
            return NSLocalizedString(@"Alert when price drops quickly",@"Price Alert Screen");
            break;
        default:
            return @"";
            break;
    }
}

-(NSString*)explanationForTriggerType:(DCTriggerType)triggerType {
    switch (triggerType) {
        case DCTriggerAbove:
            return NSLocalizedString(@"You will receive a notification on your device when the Dash price raises above the value entered above.",@"Price Alert Screen");
            break;
        case DCTriggerBelow:
            return NSLocalizedString(@"You will receive a notification on your device when the Dash price falls below the value entered above.",@"Price Alert Screen");
            break;
        default:
            return @"";
            break;
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (!string.length)
    {
        return YES;
    }
    
    // Prevent invalid character input, if keyboard is numberpad
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet].invertedSet].location != NSNotFound)
        {
            return NO;
        }
    }
    
    // verify max length has not been exceeded
    NSString *proposedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (proposedText.length > 6) // Let's not let users go crazy either :P
    {
        // suppress the max length message only when the user is typing
        // easy: pasted data has a length greater than 1; who copy/pastes one character?
        if (string.length > 1)
        {
            // BasicAlert(@"", @"This field accepts a maximum of 4 characters.");
        }
        
        return NO;
    }
    
    return YES;
}

-(void)addTrigger:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSNumber * value = @([self.priceAmountTableViewCell.priceTextField.text integerValue]);
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        DCTrigger * trigger = [[DCTrigger alloc] initWithType:self.triggerType value:value market:@"DASH_USD"];
        [[DCBackendManager sharedInstance] postTrigger:trigger completion:^(NSError * _Nullable triggerError,NSUInteger statusCode, id response) {
            // Do something...
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSError * error = triggerError;
                if (!error && response) {
                    NSDictionary * dictionary = ((NSDictionary*)response);
                    NSManagedObjectContext * context = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
                    DCTriggerEntity *triggerEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DCTriggerEntity" inManagedObjectContext:context];
                    triggerEntity.identifier = [[dictionary objectForKey:@"id"] unsignedLongLongValue];
                    triggerEntity.value = [[dictionary objectForKey:@"value"] unsignedLongLongValue];
                    triggerEntity.type = [DCTrigger typeForNetworkString:[dictionary objectForKey:@"type"]];
                    triggerEntity.marketNamed = [dictionary objectForKey:@"market"];
                    triggerEntity.ignoreFor = [[dictionary objectForKey:@"ignoreFor"] unsignedLongLongValue];
                    triggerEntity.market = [[DCCoreDataManager sharedInstance] marketNamed:[dictionary objectForKey:@"market"] inContext:context error:&error];
                    NSString * exchangeName = [dictionary objectForKey:@"exchange"];
                    if (![exchangeName isEqualToString:@"any"]) {
                        triggerEntity.exchangeNamed = exchangeName;
                        triggerEntity.exchange = [[DCCoreDataManager sharedInstance] exchangeNamed:exchangeName inContext:context error:&error];
                    }
                    
                    NSError * error = nil;
                    if (![context save:&error]) {
                        NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                        abort();
                    }
                    [self.navigationController popViewControllerAnimated:TRUE];
                    if (!error) {
                        return;
                    }
                }
                NSString * message = nil;
                if (statusCode == 409) {
                    message = @"You already have this exact same price alert.";
                } else if (!response) {
                    message = @"The server does not seem reachable, are you sure you are online?";
                } else {
                    message = @"Local error, please try again.";
                }
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok",@"ok") style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alertController animated:TRUE completion:^{
                        
                    }];
                
            });
        }];
        
    });
}

@end
