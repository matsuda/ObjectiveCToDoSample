//
//  UITableView+Extensions.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "UITableView+Extensions.h"

@implementation UITableView (Extensions)

- (void)xxx_selectRowAtFirstRespondingView:(UIView *)current
{
    NSIndexPath *indexPath = [self xxx_indexPathAtFirstRespondingView:current];
    if (indexPath) {
        [self xxx_flashRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)xxx_indexPathAtFirstRespondingView:(UIView *)current
{
    UIView *view = current.superview;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    if ([view isKindOfClass:[UITableViewCell class]]) {
        return [self indexPathForCell:(UITableViewCell *)view];
    }
    return nil;
}

- (void)xxx_flashRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    static CGFloat delay = 0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self deselectRowAtIndexPath:indexPath animated:YES];
    });
}

@end
