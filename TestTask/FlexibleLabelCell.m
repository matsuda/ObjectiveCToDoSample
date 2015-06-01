//
//  FlexibleLabelCell.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "FlexibleLabelCell.h"

@implementation FlexibleLabelCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.frame.size.width;
    [super layoutSubviews];
}

@end
