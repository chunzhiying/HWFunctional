//
//  STestCollectionViewCell.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/8.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "STestCollectionViewCell.h"

@implementation STestCollectionViewCell

+ (instancetype)initFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:@"STestCollectionViewCell" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
