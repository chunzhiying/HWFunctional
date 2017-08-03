//
//  TestTableViewCell.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/3.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "TestTableViewCell.h"

@implementation TestTableViewCell

+ (instancetype)initFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:@"TestTableViewCell" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateUIWithColor:(UIColor *)color {
    
}

@end
