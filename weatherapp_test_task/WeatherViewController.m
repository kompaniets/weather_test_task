//
//  ViewController.m
//  weatherapp_test_task
//
//  Created by Andrey Kompaniets on 22.09.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import "WeatherViewController.h"
#import "WeatherModel.h"
#import "CellForWeather.h"
#import "WeatherData.h"

@interface WeatherViewController () <WeatherHTTPDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) WeatherModel *weatherModel;
@property (strong, nonatomic) NSArray *arrayWithWeatherData;

@property (weak, nonatomic) IBOutlet UIView *customAlertView;
@property (weak, nonatomic) IBOutlet UILabel *alertViewTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewConstraint;

@end

@implementation WeatherViewController


#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.weatherModel = [WeatherModel new];
    [self.backgroundImage setImage:[UIImage imageNamed:@"1"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)refreshCollectionView{
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_arrayWithWeatherData) {
        [self.weatherModel getWeatherWithDelegate:self];
    }
    
}


#pragma mark - Color

- (UIColor *)colorFromRGB:(NSInteger)rgbValue{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0 alpha:1];
}


#pragma mark -

- (IBAction)getWeater:(id)sender {
    [self.weatherModel getWeatherWithDelegate:self];
}


#pragma mark - Today View

- (void)configureTodayView{
    WeatherData * sObject  = [self.arrayWithWeatherData objectAtIndex:0];
    [self.todayBackgroundImage setImage:[UIImage imageNamed:@"title_image"]];
    [self.todayWeatherIcon setImage:[UIImage imageNamed:sObject.code]];
    [self.todayTemp setText:[NSString stringWithFormat:@"%@, %@", sObject.temperature, sObject.info]];
    [self.todayWeatherDate setText:sObject.date];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [_arrayWithWeatherData count ] - 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *const cellID = @"weatherCell";
    CellForWeather *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    WeatherData * wObject  = [self.arrayWithWeatherData objectAtIndex:indexPath.row+1];
    [cell.cellBackground setImage:[[UIImage imageNamed:@"cell_background"] stretchableImageWithLeftCapWidth:50 topCapHeight:50]];
    [cell.weatherIcon setImage:[UIImage imageNamed:wObject.code]];
    [cell.weatherDesc setText:wObject.info];
    [cell.temperature setText:wObject.temperature];
    [cell.date setText:wObject.date];
    
    return cell;
}


#pragma mark -  WeatherHTTPDelegate

- (void)weatherClient:(WeatherModel *)client didGetWeather:(NSArray *)weatherDetail fromDataBase:(BOOL)fromDB{
    
    if (weatherDetail) {
        
        self.arrayWithWeatherData = [NSArray arrayWithArray:weatherDetail];
        if (!fromDB) {
            [self showCustomAlertWithTitle:@"The weather updated successfully!"
                                  andColor:[self colorFromRGB:0x51ba51]];
        }
        
        [self refreshCollectionView];
        
        [self configureTodayView];
    }
}

- (void)weatherClient:(WeatherModel *)client didFailWithError:(NSError *)error{
#if DEBUG
    NSLog(@"Error %@", error);
#endif
    [self showCustomAlertWithTitle:@"Network error!" andColor:[self colorFromRGB:0xf43131]];
}


#pragma mark - Custom Alert View

- (void)showCustomAlertWithTitle:(NSString*)title andColor:(UIColor*)color{
    
    [self.customAlertView setBackgroundColor:color];
    [self.alertViewTitle setText:title];
    self.alertViewConstraint.constant = 0.0f;
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         [self.view layoutIfNeeded];
                         
                     } completion:^(BOOL finished) {
                         if (finished) {
                             self.alertViewConstraint.constant = -45.0f;
                             [UIView animateWithDuration:0.5f delay:1.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                                 [self.view layoutIfNeeded];
                             } completion:nil];
                         }
                     }];
}

@end
