//
//  ViewController.h
//  weatherapp_test_task
//
//  Created by Andrey Kompaniets on 22.09.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


//Today Weather View
@property (weak, nonatomic) IBOutlet UIView *todayView;
@property (weak, nonatomic) IBOutlet UIImageView *todayBackgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *todayTemp;
@property (weak, nonatomic) IBOutlet UILabel *todayWeatherDate;
@property (weak, nonatomic) IBOutlet UIImageView *todayWeatherIcon;

- (IBAction)getWeater:(id)sender;

@end

