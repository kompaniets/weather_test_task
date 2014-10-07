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
#import <TSMessages/TSMessage.h>

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
    
    self.weatherModel = [WeatherModel sharedModel];
    [self.backgroundImage setImage:[UIImage imageNamed:@"1"]];
    
    [super viewDidLoad];
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
    if (!_arrayWithWeatherData || ![_arrayWithWeatherData count]) {
        [self.weatherModel getWeatherWithDelegate:self];
    }
    
}


#pragma mark -

- (IBAction)getWeater:(id)sender {
    [self.weatherModel getWeatherWithDelegate:self];
}


#pragma mark - Today View

- (void)configureTodayView{
    [self.todayBackgroundImage setImage:[UIImage imageNamed:@"title_image"]];
    [self.todayWeatherIcon setImage:[UIImage imageNamed:((WeatherData*)[self.arrayWithWeatherData objectAtIndex:0]).code]];
    [self.todayTemp setText:[NSString stringWithFormat:@"%@, %@",
                            ((WeatherData*)[self.arrayWithWeatherData objectAtIndex:0]).temperature,
                             ((WeatherData*)[self.arrayWithWeatherData objectAtIndex:0]).info]];
    [self.todayWeatherDate setText:((WeatherData*)[self.arrayWithWeatherData objectAtIndex:0]).date];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [_arrayWithWeatherData count ] - 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *const cellID = @"weatherCell";
    CellForWeather *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    if (_arrayWithWeatherData) {

        [cell.cellBackground setImage:[[UIImage imageNamed:@"cell_background"] stretchableImageWithLeftCapWidth:50 topCapHeight:50]];
        [cell.weatherIcon setImage:[UIImage imageNamed:((WeatherData*)[self.arrayWithWeatherData objectAtIndex:indexPath.row+1]).code]];
        [cell.weatherDesc setText:((WeatherData*)[self.arrayWithWeatherData objectAtIndex:indexPath.row+1]).info];
        [cell.temperature setText:((WeatherData*)[self.arrayWithWeatherData objectAtIndex:indexPath.row+1]).temperature];
        [cell.date setText:((WeatherData*)[self.arrayWithWeatherData objectAtIndex:indexPath.row+1]).date];
    }
    
    return cell;
}


#pragma mark -  WeatherHTTPDelegate

- (void)weatherClient:(WeatherModel *)client didGetWeather:(NSArray *)weatherDetail fromDataBase:(BOOL)fromDB{
    
    if (weatherDetail) {

        self.arrayWithWeatherData = [NSArray arrayWithArray:weatherDetail];
        if (!fromDB) {
            [TSMessage showNotificationInViewController:self
                                                  title:@"Success!"
                                               subtitle:@"The weather was updated."
                                                   type:TSMessageNotificationTypeSuccess];
        }
        
        [self refreshCollectionView];

        [self configureTodayView];
    }
}

- (void)weatherClient:(WeatherModel *)client didFailWithError:(NSError *)error{
#if DEBUG
    NSLog(@"Error %@", error);
#endif
    [TSMessage showNotificationInViewController:self
                                          title:@"Error!"
                                       subtitle:@"Probably, internet connection now is unavailable."
                                           type:TSMessageNotificationTypeWarning];
}


#pragma mark - Custom Alert View

- (void)showCustomAlertWithTitle:(NSString*)title andColor:(UIColor*)color{
    
    [self.customAlertView setBackgroundColor:color];
    [self.alertViewTitle setText:title];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.alertViewConstraint.constant = 0.0f;
                         [self.view layoutIfNeeded];
                     }];
 
    [UIView animateWithDuration:0.5f delay:1.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.alertViewConstraint.constant = -45.0f;
        [self.view layoutIfNeeded];
    } completion:nil];
}

@end
