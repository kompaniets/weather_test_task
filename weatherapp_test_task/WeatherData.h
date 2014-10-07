//
//  WeatherData.h
//  weatherapp_test_task
//
//  Created by Andrey Kompaniets on 30.09.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WeatherData : NSManagedObject

@property (nonatomic, retain) NSString * temperature;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * date;

@end
