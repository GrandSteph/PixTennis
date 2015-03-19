//
//  AppDelegate.h
//  PixTennis
//
//  Created by GrandSteph on 3/18/15.
//  Copyright (c) 2015 GrandSteph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import <PubNub/PNImports.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,PNDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

