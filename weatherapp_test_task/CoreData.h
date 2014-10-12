//
//  CoreData.h
//  weatherapp_test_task
//
//  Created by Andrey Kompaniets on 12.10.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreData : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreData *)coreDataModel;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
