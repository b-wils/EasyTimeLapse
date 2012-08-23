//
//  ETLAppDelegate.h
//  ETL-interface-test
//
//  Created by Carll Hoffman on 6/18/12.
//  Copyright (c) 2012 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorSwitcher.h"

@class ETLHomeController;
@class ETLDeviceInterface;

@interface ETLAppDelegate : UIResponder <UIApplicationDelegate>
{
    ETLDeviceInterface * deviceInterface;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ETLHomeController *viewController;
@property (nonatomic, strong) ColorSwitcher * colorSwitcher;
+ (ETLAppDelegate*)instance;

@end
