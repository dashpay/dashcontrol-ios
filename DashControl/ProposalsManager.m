//
//  ProposalsManager.m
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalsManager.h"

#define DASH_PROPOSALS_BUDGET_URL @"https://www.dashcentral.org/api/v1/budget"
#define DASH_PROPOSAL_DETAIL_URL @"https://www.dashcentral.org/api/v1/proposal"

/**
 This creates a new query parameters string from the given NSDictionary. For
 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
 string will be @"day=Tuesday&month=January".
 @param queryParameters The input dictionary.
 @return The created parameters string.
 */
static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                          [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

/**
 Creates a new URL by adding the given query parameters.
 @param URL The input URL.
 @param queryParameters The query parameter dictionary to add.
 @return A new NSURL.
 */
static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
                           [URL absoluteString],
                           NSStringFromQueryParameters(queryParameters)
                           ];
    return [NSURL URLWithString:URLString];
}

@interface ProposalsManager ()
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation ProposalsManager
@synthesize managedObjectContext;

#pragma mark - Singleton Init Methods

+ (id)sharedManager {
    static ProposalsManager *sharedProposalsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProposalsManager = [[self alloc] init];
    });
    return sharedProposalsManager;
}

- (id)init {
    if (self = [super init]) {
        self.managedObjectContext = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self fetchBudgetAndProposals];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Fetch Budget / Proposals

-(void)fetchBudgetAndProposals {

    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];

    NSURL* URL = [NSURL URLWithString:DASH_PROPOSALS_BUDGET_URL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2)) {
                NSLog(@"Status %ld",(long)((NSHTTPURLResponse*)response).statusCode);
                return;
            }
            NSError *e = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:&e];
            
            if (!e) {
                //Save info about budget.
                [self updateBudget:[jsonDic objectForKey:@"budget"]];
                
                //Update proposals list
                if ([jsonDic objectForKey:@"proposals"] && [[jsonDic objectForKey:@"proposals"] count]) {
                    [self updateProposals:[jsonDic objectForKey:@"proposals"]];
                }
            }
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

-(void)fetchProposalDetailWithHash:(NSString*)hashProposal {

    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];

    NSURL* URL = [NSURL URLWithString:DASH_PROPOSAL_DETAIL_URL];
    NSDictionary* URLParams = @{
                                @"hash": hashProposal,
                                };
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2)) {
                NSLog(@"Status %ld",(long)((NSHTTPURLResponse*)response).statusCode);
                return;
            }
            NSError *e = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:&e];
            
            if (!e) {
                if ([jsonDic objectForKey:@"proposal"] && [jsonDic objectForKey:@"proposal"] != [NSNull null]) {
                    [self updateProposals:[jsonDic objectForKey:@"proposal"]];
                }
                if ([jsonDic objectForKey:@"comments"] && [jsonDic objectForKey:@"proposal"] != [NSNull null]) {
                    [self updateComments:[jsonDic objectForKey:@"comments"] forProposalHash:[[jsonDic objectForKey:@"proposal"] objectForKey:@"hash"]];
                }
            }
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

#pragma mark - Core Data related

-(void)updateBudget:(NSDictionary *)jsonDic {
    NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        
        Budget *budget;
        NSMutableArray *existingBudgets = [self fetchAllObjectsForEntity:@"Budget" inContext:context];
        if (existingBudgets.count == 0) {
            budget = [NSEntityDescription insertNewObjectForEntityForName:@"Budget" inManagedObjectContext:context];
        } else {
            budget = existingBudgets.firstObject;
        }
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        budget.totalAmount = [jsonDic objectForKey:@"total_amount"];
        budget.allotedAmount = [[jsonDic objectForKey:@"alloted_amount"] doubleValue];
        budget.paymentDate = [df dateFromString:[jsonDic objectForKey:@"payment_date"]];
        budget.paymentDateHuman = [jsonDic objectForKey:@"payment_date_human"];
        budget.superblock = [jsonDic objectForKey:@"superblock"];

        context.automaticallyMergesChangesFromParent = TRUE;
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        else {
            
        }
    }];
}

-(void)updateProposals:(id)jsonObj {
    NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        
        NSMutableArray *proposalsArray = [NSMutableArray new];
        [jsonObj isKindOfClass:[NSArray class]] ? [proposalsArray addObjectsFromArray:(NSArray*)jsonObj] : [proposalsArray addObject:jsonObj];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        for (NSDictionary *proposalDic in proposalsArray) {
            
            Proposal *proposal;
            NSMutableArray *existingProposal = [self fetchProposalWithHash:[proposalDic objectForKey:@"hash"] inContext:context];
            if (!existingProposal.count) {
                proposal = [NSEntityDescription insertNewObjectForEntityForName:@"Proposal" inManagedObjectContext:context];
                proposal.hashProposal = [proposalDic objectForKey:@"hash"];
            }
            else {
                proposal = existingProposal.firstObject;
            }
            
            proposal.name = [proposalDic objectForKey:@"name"];
            proposal.url = [proposalDic objectForKey:@"url"];
            proposal.dwUrl = [proposalDic objectForKey:@"dw_url"];
            proposal.dwUrlComments = [proposalDic objectForKey:@"dw_url_comments"];
            proposal.title = [proposalDic objectForKey:@"title"];
            proposal.dateAdded = [df dateFromString:[proposalDic objectForKey:@"date_added"]];
            proposal.dateAddedHuman = [proposalDic objectForKey:@"date_added_human"];
            proposal.dateEnd = [df dateFromString:[proposalDic objectForKey:@"date_end"]];
            proposal.votingDeadlineHuman = [proposalDic objectForKey:@"voting_deadline_human"];
            proposal.willBeFunded = [proposalDic objectForKey:@"will_be_funded"];
            proposal.remainingYesVotesUntilFunding = [proposalDic objectForKey:@"remaining_yes_votes_until_funding"];
            proposal.inNextBudget = [proposalDic objectForKey:@"in_next_budget"];
            proposal.monthlyAmount = [[proposalDic objectForKey:@"monthly_amount"] doubleValue];
            proposal.totalPaymentCount = [[proposalDic objectForKey:@"total_payment_count"] intValue];
            proposal.remainingPaymentCount = [[proposalDic objectForKey:@"remaining_payment_count"] intValue];
            proposal.yes = [[proposalDic objectForKey:@"yes"] boolValue];
            proposal.no = [[proposalDic objectForKey:@"no"] boolValue];
            proposal.abstain = [[proposalDic objectForKey:@"abstain"] intValue];
            proposal.commentAmount = [[proposalDic objectForKey:@"comment_amount"] intValue];
            proposal.ownerUsername = [proposalDic objectForKey:@"owner_username"];
            
            if ([proposalDic objectForKey:@"description_base64_bb"]) {
                proposal.descriptionBase64Bb = [proposalDic objectForKey:@"description_base64_bb"];
            }
            if ([proposalDic objectForKey:@"description_base64_html"]) {
                proposal.descriptionBase64Html = [proposalDic objectForKey:@"description_base64_html"];
            }

            if ([jsonObj isKindOfClass:[NSArray class]]) {
                [self fetchProposalDetailWithHash:[proposalDic objectForKey:@"hash"]];
            }
        }

        context.automaticallyMergesChangesFromParent = TRUE;
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        else {
            
        }
    }];
}

-(void)updateComments:(NSArray*)commentsArray forProposalHash:(NSString *)proposalHash {
    
    NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        
        Proposal *proposal;
        NSMutableArray *existingProposal = [self fetchProposalWithHash:proposalHash inContext:context];
        if (!existingProposal.count) {
            return;
        }
        else {
            proposal = existingProposal.firstObject;
        }

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        for (NSDictionary *commentDic in commentsArray) {
            
            Comment *comment;
            NSMutableArray *existingComment = [self fetchCommentWithId:[commentDic objectForKey:@"id"] inContext:context];
            if (!existingComment.count) {
                comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
                comment.idComment = [commentDic objectForKey:@"id"];
            }
            else {
                comment = existingComment.firstObject;
            }
            
            comment.username = [commentDic objectForKey:@"username"];
            comment.date = [df dateFromString:[commentDic objectForKey:@"date"]];
            comment.dateHuman = [commentDic objectForKey:@"date_human"];
            comment.order = [[commentDic objectForKey:@"order"] intValue];
            comment.level = [commentDic objectForKey:@"level"];
            comment.recentlyPosted = [[commentDic objectForKey:@"recently_posted"] boolValue];
            comment.postedByOwner = [[commentDic objectForKey:@"posted_by_owner"] boolValue];
            comment.replyUrl = [commentDic objectForKey:@"reply_url"];
            comment.content = [commentDic objectForKey:@"content"];
            
            if (![proposal.comments containsObject:comment]) {
                [proposal addCommentsObject:comment];
            }
        }
        
        context.automaticallyMergesChangesFromParent = TRUE;
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        else {
            
        }
    }];
}

-(NSMutableArray *)fetchProposalWithHash:(NSString *)hashProposal inContext:(NSManagedObjectContext *)context {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Proposal" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *hashPredicate = [NSPredicate predicateWithFormat:@"hashProposal == %@", hashProposal];
        [request setPredicate:hashPredicate];
        
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        if (array == nil)
        {
            NSLog(@"Error while festching %@ with predicate %@", entityDescription.name, hashPredicate);
        }
        return [array mutableCopy];
    } else {
        return  nil;
    }
}

-(NSMutableArray *)fetchCommentWithId:(NSString *)idComment inContext:(NSManagedObjectContext *)context {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Comment" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *commentPredicate = [NSPredicate predicateWithFormat:@"idComment == %@", idComment];
        [request setPredicate:commentPredicate];
        
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        if (array == nil)
        {
            NSLog(@"Error while festching %@ with predicate %@", entityDescription.name, commentPredicate);
        }
        return [array mutableCopy];
    } else {
        return  nil;
    }
}

-(NSMutableArray*)fetchAllObjectsForEntity:(NSString*)entityName inContext:(NSManagedObjectContext *)context {
    if (context) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        [request setEntity:entity];
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[context executeFetchRequest:request error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error.
            NSLog(@"Error while fetching all %@ from DB", entityName);
        }
        return mutableFetchResults;
    } else {
        return nil;
    }
}


@end
