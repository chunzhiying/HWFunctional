//
//  TestCollectionViewCell.m
//  HWRxObserverDemo
//
//  Created by 陈智颖 on 2017/8/8.
//  Copyright © 2017年 YY. All rights reserved.
//

#import "TestCollectionViewCell.h"

@implementation TestCollectionViewCell

+ (instancetype)initFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:@"TestCollectionViewCell" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
