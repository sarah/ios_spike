//
//  AppDelegate.h
//  spike8
//
//  Created by sarah gray on 11/15/11.
//  Copyright (c) 2011 fabled net. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CouchDatabase;
@class CouchPersistentReplication;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CouchPersistentReplication *pullRequest;
@property (nonatomic, retain) CouchDatabase *localCouch;

-(void) performRemoteSync;
-(void) listQuestions;
@end
