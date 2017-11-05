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
    self.triggerTypeTableViewCell.typeLabel.text = [self textForTriggerType:DCTriggerOver];
    
    self.addTriggerTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"AddTriggerCell"];
    self.triggerType = DCTriggerOver;
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
        for (NSInteger i = 0;i<DCTriggerUnder + 1;i++) {
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
        case DCTriggerOver:
            return NSLocalizedString(@"Alert when over",@"Price Alert Screen");
            break;
        case DCTriggerUnder:
            return NSLocalizedString(@"Alert when under",@"Price Alert Screen");
            break;
        default:
            break;
    }
}

-(NSString*)explanationForTriggerType:(DCTriggerType)triggerType {
    switch (triggerType) {
        case DCTriggerOver:
            return NSLocalizedString(@"You will receive a notification on your device when the Dash price raises above the value entered above.",@"Price Alert Screen");
            break;
        case DCTriggerUnder:
            return NSLocalizedString(@"You will receive a notification on your device when the Dash price falls below the value entered above.",@"Price Alert Screen");
            break;
        default:
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
    NSManagedObjectContext * context = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
    DCTriggerEntity *triggerEntity = [NSEntityDescription insertNewObjectForEntityForName:@"DCTriggerEntity" inManagedObjectContext:context];
    triggerEntity.value = [self.priceAmountTableViewCell.priceTextField.text integerValue];
    triggerEntity.type = self.triggerType;
    NSError * error = nil;
    if (![context save:&error]) {
        NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
