//
//  STestCollectionViewCell.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/8.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STestCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
+ (instancetype)initFromNib;
@end
