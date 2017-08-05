//
//  STestTableViewCell.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/5.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STestTableViewCell : UITableViewCell

+ (instancetype)initFromNib;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
