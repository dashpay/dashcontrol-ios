//
//  DCProposalsManager.m
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCProposalsManager.h"

#import "DCPersistenceStack.h"

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
                          [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]],
                          [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]
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

@interface DCProposalsManager ()
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation DCProposalsManager

#pragma mark - Singleton Init Methods

+ (id)sharedManager {
    static DCProposalsManager *sharedProposalsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProposalsManager = [[self alloc] init];
    });
    return sharedProposalsManager;
}

- (id)init {
    if (self = [super init]) {
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
                
                NSMutableArray *proposalsArray = [[jsonDic objectForKey:@"proposals"] mutableCopy];
                //Uncomment to test Updating 'non-active' proposal
                //[proposalsArray removeAllObjects];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateProposals:proposalsArray];
                });
                
                //Since the list returned include only 'active' proposals at the moment.
                //We want to update 'non-active' proposals we may still have in coredata by calling fetchProposalsWithHash:
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
                    NSMutableArray *existingProposals = [self fetchAllObjectsForEntity:@"DCProposalEntity" inContext:viewContext];
                    NSMutableArray *proposalsToUpdate = [NSMutableArray new];
                    
                    for (DCProposalEntity *proposal in existingProposals) {
                        __block BOOL bProposalFoundInResponse = NO;
                        [proposalsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSDictionary *dic = obj;
                            if ([[dic objectForKey:@"hash"] isEqualToString:proposal.hashProposal]) {
                                bProposalFoundInResponse = YES;
                                *stop = YES;
                            }
                        }];
                        if (!bProposalFoundInResponse) {
                            [proposalsToUpdate addObject:proposal];
                        }
                    }
                    if (proposalsToUpdate.count) {
                        for (DCProposalEntity *proposal in proposalsToUpdate) {
                            proposal.order = INT32_MAX;
                            NSError *error;
                            [viewContext save:&error];
                            if (!error) {
                                NSLog(@"Updating 'non-active' proposal:%@", proposal.title);
                                [self fetchProposalsWithHash:proposal.hashProposal];
                            }
                        }
                    }
                });
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
-(void)fetchProposalsWithHash:(NSString *)hashProposal {
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    
    NSURL* URL = [NSURL URLWithString:DASH_PROPOSAL_DETAIL_URL];
    NSDictionary* URLParams = @{
                                @"hash": hashProposal,
                                };
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            if (((((NSHTTPURLResponse*)response).statusCode /100) != 2)) {
                NSLog(@"Status %ld",(long)((NSHTTPURLResponse*)response).statusCode);
                return;
            }
            NSError *e = nil;
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableLeaves error:&e];
            
            if (!e) {
                NSMutableDictionary *proposalDic = [NSMutableDictionary new];
                if ([jsonDic objectForKey:@"proposal"] && [jsonDic objectForKey:@"proposal"] != [NSNull null]) {
                    for (NSString *key in [jsonDic objectForKey:@"proposal"]) {
                        [proposalDic setObject:[[jsonDic objectForKey:@"proposal"] objectForKey:key] forKey:key];
                    }
                }
                if ([jsonDic objectForKey:@"comments"] && [jsonDic objectForKey:@"proposal"] != [NSNull null]) {
                    [proposalDic setObject:[jsonDic objectForKey:@"comments"] forKey:@"comments"];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateProposals:[NSArray arrayWithObject:proposalDic]];
                });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSPersistentContainer *container = self.stack.persistentContainer;
        [container performBackgroundTask:^(NSManagedObjectContext *context) {
            
            DCBudgetEntity *budget;
            NSMutableArray *existingBudgets = [self fetchAllObjectsForEntity:@"DCBudgetEntity" inContext:context];
            if (existingBudgets.count == 0) {
                budget = [NSEntityDescription insertNewObjectForEntityForName:@"DCBudgetEntity" inManagedObjectContext:context];
            } else {
                budget = existingBudgets.firstObject;
            }
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            budget.totalAmount = [[jsonDic objectForKey:@"total_amount"] doubleValue];
            budget.allotedAmount = [[jsonDic objectForKey:@"alloted_amount"] doubleValue];
            budget.paymentDate = [df dateFromString:[jsonDic objectForKey:@"payment_date"]];
            budget.paymentDateHuman = [jsonDic objectForKey:@"payment_date_human"];
            budget.superblock = [[jsonDic objectForKey:@"superblock"] intValue];
            
            context.automaticallyMergesChangesFromParent = TRUE;
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:BUDGET_DID_UPDATE_NOTIFICATION
                                                      object:nil
                                                    userInfo:nil];
                });
            }
        }];
    });
}

-(void)updateProposals:(NSArray *)proposalsArray {
    
    NSPersistentContainer *container = self.stack.persistentContainer;
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        for (NSDictionary *proposalDictionary in proposalsArray) {
            
            DCProposalEntity *proposal;
            NSMutableArray *existingProposal = [self fetchProposalWithHash:[proposalDictionary objectForKey:@"hash"] inContext:context];
            if (!existingProposal.count) {
                proposal = [NSEntityDescription insertNewObjectForEntityForName:@"DCProposalEntity" inManagedObjectContext:context];
                proposal.hashProposal = [proposalDictionary objectForKey:@"hash"];
            }
            else {
                proposal = existingProposal.firstObject;
            }
            
            proposal.name = [proposalDictionary objectForKey:@"name"];
            proposal.url = [proposalDictionary objectForKey:@"url"];
            proposal.dwUrl = [proposalDictionary objectForKey:@"dw_url"];
            proposal.dwUrlComments = [proposalDictionary objectForKey:@"dw_url_comments"];
            proposal.title = [proposalDictionary objectForKey:@"title"];
            proposal.dateAdded = [df dateFromString:[proposalDictionary objectForKey:@"date_added"]];
            proposal.dateAddedHuman = [proposalDictionary objectForKey:@"date_added_human"];
            proposal.dateEnd = [df dateFromString:[proposalDictionary objectForKey:@"date_end"]];
            proposal.votingDeadlineHuman = [proposalDictionary objectForKey:@"voting_deadline_human"];
            proposal.willBeFunded = [[proposalDictionary objectForKey:@"will_be_funded"] boolValue];
            proposal.remainingYesVotesUntilFunding = [[proposalDictionary objectForKey:@"remaining_yes_votes_until_funding"] intValue];
            proposal.inNextBudget = [[proposalDictionary objectForKey:@"in_next_budget"] boolValue];
            proposal.monthlyAmount = [[proposalDictionary objectForKey:@"monthly_amount"] intValue];
            proposal.totalPaymentCount = [[proposalDictionary objectForKey:@"total_payment_count"] intValue];
            proposal.remainingPaymentCount = [[proposalDictionary objectForKey:@"remaining_payment_count"] intValue];
            proposal.yes = [[proposalDictionary objectForKey:@"yes"] intValue];
            proposal.no = [[proposalDictionary objectForKey:@"no"] intValue];
            proposal.abstain = [[proposalDictionary objectForKey:@"abstain"] intValue];
            proposal.commentAmount = [[proposalDictionary objectForKey:@"comment_amount"] intValue];
            proposal.ownerUsername = [proposalDictionary objectForKey:@"owner_username"];
            
            if ([proposalDictionary objectForKey:@"order"] && [proposalDictionary objectForKey:@"order"] != [NSNull null])
                proposal.order = [[proposalDictionary objectForKey:@"order"] intValue];
            
            if ([proposalDictionary objectForKey:@"description_base64_bb"]) {
                proposal.descriptionBase64Bb = [proposalDictionary objectForKey:@"description_base64_bb"];
            }
            if ([proposalDictionary objectForKey:@"description_base64_html"]) {
                proposal.descriptionBase64Html = [proposalDictionary objectForKey:@"description_base64_html"];
            }
            if ([proposalDictionary objectForKey:@"comments"]) {
                for (NSDictionary *commentDic in [proposalDictionary objectForKey:@"comments"]) {
                    DCCommentEntity *comment;
                    NSMutableArray *existingComment = [self fetchCommentWithId:[commentDic objectForKey:@"id"] inContext:context];
                    if (!existingComment.count) {
                        comment = [NSEntityDescription insertNewObjectForEntityForName:@"DCCommentEntity" inManagedObjectContext:context];
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
                    
                    comment.hashProposal = proposal.hashProposal;
                    
                    if (![proposal.comments containsObject:comment]) {
                        [proposal addCommentsObject:comment];
                    }
                }
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
            
            if (proposalsArray.count == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:PROPOSAL_DID_UPDATE_NOTIFICATION
                                                      object:nil
                                                    userInfo:@{@"hash":[proposalsArray.firstObject objectForKey:@"hash"]}];
                });
            }
        }
    }];
}
/*
-(void)updateComments:(NSArray*)commentsArray forProposalHash:(NSString *)proposalHash {
    
    NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        
        DCProposalEntity *proposal;
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
            
            comment.hashProposal = proposalHash;
#warning See why context fails to save when adding relationship
            //            if (![proposal.comments containsObject:comment]) {
            //                [proposal addCommentsObject:comment];
            //            }
        }
        
        context.automaticallyMergesChangesFromParent = TRUE;
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
    }];
}
*/
-(NSMutableArray *)fetchProposalWithHash:(NSString *)hashProposal inContext:(NSManagedObjectContext *)context {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCProposalEntity" inManagedObjectContext:context];
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
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCCommentEntity" inManagedObjectContext:context];
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
