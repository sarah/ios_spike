//
//  AppDelegate.m
//  spike8
//
//  Created by sarah gray on 11/15/11.
//  Copyright (c) 2011 fabled net. All rights reserved.
//

#import "AppDelegate.h"
#import "CouchCocoa/CouchCocoa.h"
#import "Couchbase/CouchbaseMobile.h"

#define kDatabaseName @"spike459"
#define kRemoteSyncURL @"http://microtrendiary.iriscouch.com/microtrendiary_test/"
#define kQuestionFilter @"todays_question/questions"

@implementation AppDelegate

@synthesize window = _window;
@synthesize localCouch, pullRequest;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    CouchEmbeddedServer *server = [[CouchEmbeddedServer alloc]init];
    [server start: ^{
        if(server.error)
        {
            NSLog(@"There was an error: %@", server.error);
        }
        
        self.localCouch = [server databaseNamed:kDatabaseName];
        NSError *error;
        if(![self.localCouch ensureCreated:&error])
        {
            NSLog(@"Couldn't create db: %@", error);
        } else {
            NSLog(@"Created!");
        }
        
        localCouch.tracksChanges = YES;
        NSLog(@"Started server: %@ with db: %@", server, localCouch);
        
        [self performRemoteSync];
    }];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}
-(void) performRemoteSync
{
    NSURL *remoteURL = [NSURL URLWithString:kRemoteSyncURL];
    NSLog(@"Going to perform remote sync with: %@", remoteURL);
    self.pullRequest = [self.localCouch replicationFromDatabaseAtURL:remoteURL];
    [pullRequest setContinuous: YES];
    [pullRequest setFilter:nil];
    NSLog(@"pullRequest: %@", pullRequest);
    
    [pullRequest addObserver:self forKeyPath:@"completed" options:0 context:NULL];
    [self listQuestions];
    
}
-(void) listQuestions
{
    CouchDesignDocument *designView = [self.localCouch designDocumentWithName:@"TodaysQuestion"];
    [designView defineViewNamed:@"TodaysQuestion" 
                             map:@"function(doc){if(doc.release_date)emit(doc.release_date,doc)};"];
    
    CouchQuery* query = [designView queryViewNamed:@"TodaysQuestion"];
    query.descending = YES;
    NSLog(@"About to do the query");
    
    for(CouchQueryRow *row in query.rows)
    {
        NSLog(@"key: %@, question: %@", row.key, [row.document propertyForKey:@"main_question"]);
    }
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == pullRequest)
    {
        unsigned completed = pullRequest.completed;
        unsigned total = pullRequest.total;
        NSLog(@"completed: %u; total: %u", completed, total);
        NSLog(@"SYNC progress: %u / %u", completed, total);
        if(total > 0 && total == completed)
        {
            NSLog(@"Done syncing!");
            [pullRequest removeObserver:self forKeyPath:@"completed"];
        }
    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
