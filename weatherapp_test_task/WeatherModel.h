//
//  WeatherHTTPClient.h
//  weatherapp_test_task
//
//  Created by Andrey Kompaniets on 22.09.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

@protocol WeatherHTTPDelegate;

@interface WeatherModel : AFHTTPRequestOperationManager


@property (weak, nonatomic) id<WeatherHTTPDelegate> delegate;

- (void)getWeatherWithDelegate:(id<WeatherHTTPDelegate>)delegate;

@end

@protocol WeatherHTTPDelegate <NSObject>

- (void)weatherClient:(WeatherModel *)client didGetWeather:(NSArray *)weatherDetail fromDataBase:(BOOL)fromDB;
- (void)weatherClient:(WeatherModel *)client didFailWithError:(NSError *)error;

@end