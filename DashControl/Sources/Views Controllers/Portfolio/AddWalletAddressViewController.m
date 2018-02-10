//
//  AddWalletAddressViewController.m
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "AddWalletAddressViewController.h"
#import "NSString+Dash.h"
#import "DCWalletAddressEntity+CoreDataClass.h"
#import "BRScanViewController.h"
#import "DCWalletAddressEntity+CoreDataClass.h"

@interface AddWalletAddressViewController ()

@property(nonatomic,strong) BRScanViewController * scanController;

@end

@implementation AddWalletAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)done:(id)sender {
    if ([[self.inputField text] isValidDashAddress]) {
        NSManagedObjectContext * context = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
        DCWalletAddressEntity * walletAddress = [NSEntityDescription insertNewObjectForEntityForName:@"DCWalletAddressEntity" inManagedObjectContext:context];
        walletAddress.address = [self.inputField text];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        else {
            [self.navigationController dismissViewControllerAnimated:TRUE completion:nil];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //we kind of hacked the sender as it contains the trigger to send to the next view
    if ([segue.identifier isEqualToString:@"AddressScanSegue"]) {
        self.scanController = (BRScanViewController*)segue.destinationViewController;
        self.scanController.delegate = self;
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataMachineReadableCodeObject *codeObject in metadataObjects) {
        if (! [codeObject.type isEqual:AVMetadataObjectTypeQRCode]) continue;
        
        NSString *addr = [codeObject.stringValue stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([addr isValidDashAddress]) {
            self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide-green"];
            [self.scanController stop];
            self.inputField.text = addr;
            [self done:self];
        } else {
            self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide-red"];
            self.scanController.message.text = [NSString stringWithFormat:@"%@:\n%@",
                                                    NSLocalizedString(@"not a valid dash address", nil),
                                                    addr];
        }
        break;
    }
}


@end
