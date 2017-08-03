//
//  TestTableViewCell.h
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/3.
//  Copyright © 2017年 YY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;

+ (instancetype)initFromNib;

@end
