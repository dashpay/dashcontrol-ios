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

#import "ProposalDetailTableViewCellModel.h"

#import "DCBudgetProposalEntity+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *HTMLStringTemplate() {
    static NSString *htmlTemplate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *htmlTemplatePath = [[NSBundle mainBundle] pathForResource:@"ProposalDescriptionTemplate.html" ofType:nil];
        htmlTemplate = [NSString stringWithContentsOfFile:htmlTemplatePath encoding:NSUTF8StringEncoding error:nil];
    });
    return htmlTemplate;
}

@interface ProposalDetailTableViewCellModel ()

@property (copy, nonatomic) NSString *lastDescriptionHTML;
@property (copy, nonatomic) NSString *html;

@end

@implementation ProposalDetailTableViewCellModel

- (void)updateWithProposal:(DCBudgetProposalEntity *)proposal {
    if (!proposal.descriptionHTML) {
        return;
    }

    if (self.lastDescriptionHTML && [self.lastDescriptionHTML isEqualToString:proposal.descriptionHTML]) {
        return;
    }
    self.lastDescriptionHTML = proposal.descriptionHTML;

    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:proposal.descriptionHTML options:kNilOptions];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    self.html = [NSString stringWithFormat:HTMLStringTemplate(), decodedString];
}

@end

NS_ASSUME_NONNULL_END
