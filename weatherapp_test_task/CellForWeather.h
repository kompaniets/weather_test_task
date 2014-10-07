//
//  CellForWeather.h
//  weatherapp_test_task
//
//  Created by Andrey Kompaniets on 27.09.14.
//  Copyright (c) 2014 ARC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellForWeather : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellBackground;
@property (weak, nonatomic) IBOutlet UIImageView *weatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *weatherDesc;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
