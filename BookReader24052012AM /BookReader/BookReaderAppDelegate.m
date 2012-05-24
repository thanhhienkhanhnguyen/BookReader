//
//  BookReaderAppDelegate.m
//  BookReader
//
//  Created by mac on 3/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BookReaderAppDelegate.h"

#import "BookReaderViewController.h"

#import "FlurryAnalytics.h"



@implementation BookReaderAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize isLandscape = _isLandscape;
@synthesize arrDownload = _arrDownload;
@synthesize bgTask = _bgTask;
@synthesize isForeground = _isForeground;
@synthesize arrOwnBooks = _arrOwnBooks;
@synthesize isDownloadOwnBooks = _isDownloadOwnBooks;
@synthesize arrBooks = _arrBooks;
@synthesize queueDownloadBook = _queueDownloadBook;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    //return NO;
    
    return [self.viewController.facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //return YES;
    return [self.viewController.facebook handleOpenURL:url]; 
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FlurryAnalytics startSession:@"BBCR48X14TUH8B4ZMRNX"];
    
    self.isDownloadOwnBooks = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    _viewController = [[BookReaderViewController alloc] initWithNibName:@"BookReaderViewController" bundle:nil]; 
    self.window.rootViewController = self.viewController;
    [_viewController release];
    
    _arrDownload = [[NSMutableArray alloc] initWithObjects: nil];
    _arrOwnBooks = [[NSMutableArray alloc] initWithObjects: nil];
    _arrBooks = [[NSMutableArray alloc] initWithObjects: nil];
    
    [self.window makeKeyAndVisible];
    return YES;
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
    
    _isForeground = NO;
    
    _bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you.
        // stopped or ending the task outright.
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do the work associated with the task, preferably in chunks.
        while (1 && !_isForeground) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
            //NSLog(@"background Thread2");
        }
        [application endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    _isForeground = YES;
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
