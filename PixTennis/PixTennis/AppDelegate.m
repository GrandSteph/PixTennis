//
//  AppDelegate.m
//  PixTennis
//
//  Created by GrandSteph on 3/18/15.
//  Copyright (c) 2015 GrandSteph. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSString *uuid;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [PubNub setDelegate:self];
    self.uuid = @"StephaneChannel";
    [self ConnectToPNWithCurrentUser:self.uuid];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if (self.uuid) {
//        [PubNub updateClientState:self.uuid state:@{@"appState":@"OFFLINE",@"userNickname":self.uuid} forObject:[PNChannel channelWithName:self.uuid]];
    }
    
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background handler called. Not running background tasks anymore.");
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.uuid) {
        //[PubNub updateClientState:self.uuid state:@{@"appState":@"ONLINE",@"userNickname":self.uuid} forObject:[PNChannel channelWithName:self.uuid]];
        NSLog(@"\n *************** DID BECOME ACTIVE ************ \n");
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark PubNub
- (void) ConnectToPNWithCurrentUser:(NSString *) uuid {
    
    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                             publishKey:@"pub-c-26d47b9e-d90c-4381-8c82-4cbca42a76fc"
                                                           subscribeKey:@"sub-c-c0f526d4-b8ec-11e3-a614-02ee2ddab7fe"
                                                              secretKey:nil];
    
    [PubNub setClientIdentifier:self.uuid];
    [PubNub setConfiguration:myConfig];
    
    [self addPNObservers];
    
    [PubNub connect];
}

- (void) addPNObservers {
    

    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self withCallbackBlock:^(NSString *origin, BOOL isConnected, PNError *connectionError) {
        
        NSLog(@"********** OBSERVER  Connection State Changed **********\n");
        
        
        
        if (isConnected)
        {
            NSLog(@"OBSERVER: Successful Connection!");
 
        }
        else if (!isConnected || connectionError != nil )
        {
            NSLog(@"OBSERVER: Error %@, Connection Failed!", connectionError.localizedDescription);
            
                        if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
                            // wait 1 second
                            int64_t delayInSeconds = 1.0;
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                //PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
                                UIAlertView *reconnect = [[UIAlertView alloc] initWithTitle: @"PUBNUB - status"
                                                                                    message:@"Will Reconnect to PN when not offline anymore"
                                                                                   delegate:nil
                                                                          cancelButtonTitle: @"OK"
                                                                          otherButtonTitles: nil];
                                [reconnect show];
            
                            });
                        } else {
                            UIAlertView *connectionErrorAlert = [UIAlertView new];
                            connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",
                                                          [connectionError localizedDescription],
                                                          NSStringFromClass([self class])];
                            connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
                                                            [connectionError localizedFailureReason],
                                                            [connectionError localizedRecoverySuggestion]];
                            [connectionErrorAlert addButtonWithTitle:@"OK"];
            
                            [connectionErrorAlert show];
                        }
            
            
        }
    }];
    
}

#pragma mark PubNub delegates

- (void) pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    NSLog(@"\n\n\n didConnectToOrigin \n\n\n");
    
    PNChannel *theChannel = [PNChannel channelWithName:self.uuid shouldObservePresence:NO];
    [PubNub subscribeOn:@[theChannel]];
}

- (void) pubnubClient:(PubNub *)client didUpdateClientState:(PNClient *)remoteClient {
    NSLog(@"\n\n\n PUBNUNUB DELEGATE didUpdateClientState with state %@ \n\n\n", remoteClient);
}

- (void) pubnubClient:(PubNub *)client didRestoreSubscriptionOn:(NSArray *)channelObjects {
    NSLog(@"\n\n\n didRestoreSubscriptionOn \n\n\n");
    [PubNub updateClientState:self.uuid state:@{@"appState":@"ONLINE",@"userNickname":self.uuid} forObject:[PNChannel channelWithName:self.uuid]];
    
}

- (void) pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    NSLog(@"\n\n\n didSubscribeOn \n\n\n");
    [PubNub updateClientState:self.uuid state:@{@"appState":@"ONLINE",@"userNickname":self.uuid} forObject:[PNChannel channelWithName:self.uuid]];
}

- (void)pubnubClient:(PubNub *)client willSuspendWithBlock:(void(^)(void(^)(void(^)(void))))preSuspensionBlock {
    NSLog(@"\n\n\n PRESUSPENSION \n\n\n");
    
    if ([client isConnected]) {
        
        preSuspensionBlock(^(void(^completionBlock)(void)){

            [PubNub updateClientState:self.uuid state:@{@"appState":@"OFFLINE",@"userNickname":self.uuid} forObject:[PNChannel channelWithName:self.uuid] withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
                
                if (error) {
                    
                    // Handle update error
                    NSLog(@"");
                }
                self.backgroundTask = UIBackgroundTaskInvalid;
                
                // If application come back to foreground while completion block is not finished. Then update to ONLINE.
                // If would otherwise complete this stay in OFFLINE state
                if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
                    [PubNub updateClientState:self.uuid state:@{@"appState":@"ONLINE",@"userNickname":self.uuid} forObject:[PNChannel channelWithName:self.uuid]];
                }
                completionBlock();
            }];
        });
    }
}

- (void) pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    NSLog(@"PUBNUNUB DELEGATE didReceiveMessage %@", message.message);
    NSDictionary *messageContent = [NSDictionary dictionaryWithDictionary:message.message];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"message" object:self userInfo:messageContent];

    
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.wavein.PixTennis" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PixTennis" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PixTennis.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
