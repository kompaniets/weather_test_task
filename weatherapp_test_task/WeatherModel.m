//
//  WeatherHTTPClient.m
//  weatherapp_test_task
//
//  Created by Andrey Kompaniets on 22.09.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//
#define urlStr @"http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20weather.forecast%20WHERE%20woeid=918981%20and%20u='c'&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="

#import "WeatherModel.h"
#import "WeatherData.h"
#import "AppDelegate.h"

@interface WeatherModel()

@property (strong, nonatomic) WeatherData *weatherData;
@property (strong, nonatomic) NSManagedObjectContext *contextObject;
@property (strong, nonatomic) NSMutableArray *weatherInfo;

@property (copy) void(^didGetWeather)(NSArray *, BOOL);
@property (copy) void(^didFailWithError)(NSError *);

@end

@implementation WeatherModel


#pragma mark - Shared Object

+ (WeatherModel *)sharedModel
{
    static dispatch_once_t pred;
    static WeatherModel *_sharedHTTPClient = nil;
    
    dispatch_once(&pred, ^{
        _sharedHTTPClient = [[WeatherModel alloc] init];
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        _sharedHTTPClient.contextObject = delegate.managedObjectContext;
        _sharedHTTPClient.weatherInfo = [[NSMutableArray alloc] init];
    });
    return _sharedHTTPClient;
}


#pragma mark - Weather data fetcher\handler

- (void)getWeatherWithDelegate:(id<WeatherHTTPDelegate>)delegate{
   
    if ([self.weatherInfo count]) {
        [self.weatherInfo removeAllObjects];
    }
    
    __weak typeof(self) weakSelf = self;
    self.didGetWeather = ^(NSArray *array, BOOL fromDataBase){
        if (delegate && [delegate respondsToSelector:@selector(weatherClient:didGetWeather:fromDataBase:)]) {
            [delegate weatherClient:weakSelf didGetWeather:array fromDataBase:fromDataBase];
        }
    };
    
    self.didFailWithError = ^(NSError *error){
        if (delegate && [delegate respondsToSelector:@selector(weatherClient:didFailWithError:)]) {
            [delegate weatherClient:weakSelf didFailWithError:error];
        }
    };
    
    if (![[self fetchWeatherDataFromDataBase] count]) {
            [self updateWeatherData];
        }else{
            self.didGetWeather([self fetchWeatherDataFromDataBase],YES);
            [self updateWeatherData];
        }
}

- (void)updateWeatherData{
        
          dispatch_queue_t queue = dispatch_queue_create("arc.weatherapp.test.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [self GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                NSArray *response = (NSArray*)[[[[[responseObject objectForKey:@"query"]
                                                  objectForKey:@"results"]
                                                 objectForKey:@"channel"]
                                                objectForKey:@"item"]
                                               objectForKey:@"forecast"];
                [self deleteAllObjectsInDataBase];
                NSArray *processedArray = [self handleWeatherData:response];
                self.didGetWeather(processedArray, NO);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (error) {
                self.didFailWithError(error);
            }
        }];
    });
}

- (NSArray *)handleWeatherData:(NSArray *)weatherArray{

    NSDateFormatter *formatter = [NSDateFormatter new];
    
    for (int a=0; [weatherArray count]>3 ? a<3 : a<[weatherArray count]; a++) {
        NSDictionary *weather = [weatherArray objectAtIndex:a];
     
        self.weatherData = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"WeatherData"
                                        inManagedObjectContext:_contextObject];
        
        [formatter setDateFormat:@"dd MMM yyyy"];
        NSDate* date = [formatter dateFromString:[weather objectForKey:@"date"]];
        [formatter setDateFormat:@"EEE dd.MM"];
        NSString *dateString = [formatter stringFromDate:date];
        self.weatherData.date = dateString;
        self.weatherData.code = (NSString*)[weather objectForKey:@"code"];
        self.weatherData.temperature = [NSString stringWithFormat:@"%@ - %@ °C",[weather objectForKey:@"low"], [weather objectForKey:@"high"]];
        self.weatherData.info = [weather objectForKey:@"text"];
        
        //Save object into data base
        [self saveObjectIntoDataBase:self.weatherData];
        //
        [self.weatherInfo addObject:self.weatherData];
    }
    return [self.weatherInfo copy];
}

- (BOOL)saveObjectIntoDataBase:(WeatherData *)data{
    
    NSError *error = nil;
    if (![self.contextObject save:&error]) {
        NSLog(@"Error --- %@", [error localizedDescription]);
        return NO;
    };
    return YES;
}

- (NSArray *)fetchWeatherDataFromDataBase{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"WeatherData" inManagedObjectContext:self.contextObject];
    [request setEntity:description];
    [request setResultType:NSManagedObjectResultType];
    
    NSError *error = nil;
    NSArray *resultArray = [self.contextObject executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error -- %@", [error localizedDescription]);
        return nil;
    }
    return resultArray;
}

- (void)deleteAllObjectsInDataBase{
    NSArray *existingObjects = [self fetchWeatherDataFromDataBase];
    for (NSManagedObject *data in existingObjects) {
        [self.contextObject deleteObject:data];
        [self.contextObject save:nil];
    }
}

@end
