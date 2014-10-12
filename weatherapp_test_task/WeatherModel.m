//
//  WeatherHTTPClient.m
//  weatherapp_test_task
//
//  Created by Andrey Kompaniets on 22.09.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//
#define urlStr @"https://query.yahooapis.com/v1/public/yql?q=SELECT%20item%20FROM%20weather.forecast%20WHERE%20woeid%3D%22918981%22%20and%20u%3D%22c%22%20%7C%20truncate(count%3D2)&format=json&diagnostics=true&callback="

#import "WeatherModel.h"
#import "WeatherData.h"
#import "AppDelegate.h"
#import "CoreData.h"

@interface WeatherModel()

@property (strong, nonatomic) WeatherData *weatherData;
@property (strong, nonatomic) CoreData *coreDataObject;
@property (strong, nonatomic) NSMutableArray *weatherInfo;

@end

@implementation WeatherModel


#pragma mark - Weather data fetcher\handler

- (void)getWeatherWithDelegate:(id<WeatherHTTPDelegate>)delegate{
    if (!self.coreDataObject && !self.weatherInfo) {
        self.coreDataObject = [CoreData coreDataModel];
        self.weatherInfo = [NSMutableArray new];
    }
    
    self.delegate = delegate;
    [self.weatherInfo removeAllObjects];
    
    if (![[self fetchWeatherDataFromDataBase] count]) {
        [self fetchWeatherDataFromServer];
    }else{
        [self didGetWeatherWithData:[self fetchWeatherDataFromDataBase] error:nil fromDataBase:YES];
        [self fetchWeatherDataFromServer];
    }
}

- (void)didGetWeatherWithData:(NSArray *)data error:(NSError *)error fromDataBase:(BOOL)fromDB{
    if (data && !error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(weatherClient:didGetWeather:fromDataBase:)]) {
            [self.delegate weatherClient:self didGetWeather:data fromDataBase:fromDB];
        }
    }else if (!data && error){
        if (self.delegate && [self.delegate respondsToSelector:@selector(weatherClient:didFailWithError:)]) {
            [self.delegate weatherClient:self didFailWithError:error];
        }
    }
}

- (void)fetchWeatherDataFromServer{

        [self GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                NSArray *response = (NSArray*)[responseObject valueForKeyPath:@"query.results.channel.item.forecast"];
                [self deleteAllObjectsInDataBase];
                    NSArray *processedArray = [self handleWeatherData:response];
                    [self didGetWeatherWithData:processedArray error:nil fromDataBase:NO];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (error) {
                [self didGetWeatherWithData:nil error:error fromDataBase:NO];
            }
        }];
}

- (NSArray *)handleWeatherData:(NSArray *)weatherArray{

    NSDateFormatter *formatter = [NSDateFormatter new];
    
    for (int a=0; [weatherArray count]>3 ? a<3 : a<[weatherArray count]; a++) {
        NSDictionary *weather = [weatherArray objectAtIndex:a];
     
        self.weatherData = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"WeatherData"
                                        inManagedObjectContext:_coreDataObject.managedObjectContext];
        
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
    return self.weatherInfo;
}

- (BOOL)saveObjectIntoDataBase:(WeatherData *)data{
    
    NSError *error = nil;
    if (![_coreDataObject.managedObjectContext save:&error]) {
        NSLog(@"Error --- %@", [error localizedDescription]);
        return NO;
    };
    return YES;
}

- (NSArray *)fetchWeatherDataFromDataBase{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"WeatherData" inManagedObjectContext:_coreDataObject.managedObjectContext];
    [request setEntity:description];
    [request setResultType:NSManagedObjectResultType];
    
    NSError *error = nil;
    NSArray *resultArray = [_coreDataObject.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error -- %@", [error localizedDescription]);
        return nil;
    }
    return [resultArray copy];
}

- (void)deleteAllObjectsInDataBase{
    NSArray *existingObjects = [self fetchWeatherDataFromDataBase];
    for (NSManagedObject *data in existingObjects) {
        [_coreDataObject.managedObjectContext deleteObject:data];
    }
    [_coreDataObject.managedObjectContext save:nil];
}

@end
