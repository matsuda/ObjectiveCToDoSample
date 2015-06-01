//
//  UIViewController+Keyboard.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "UIViewController+Keyboard.h"
#import <objc/runtime.h>

static char kScrollViewContentInsetKey;

@implementation UIViewController (Keyboard)

- (UIScrollView *)scrollViewForKeyboardNotifications
{
    return nil;
}

- (UIEdgeInsets)scrollViewContentInset
{
    NSValue *value = objc_getAssociatedObject(self, &kScrollViewContentInsetKey);
    if (value) {
        return [value UIEdgeInsetsValue];
    }
    UIScrollView *scrollView = [self scrollViewForKeyboardNotifications];
    if (scrollView) {
        UIEdgeInsets insets = scrollView.contentInset;
        [self setScrollViewContentInset:insets];
        return insets;
    }
    return UIEdgeInsetsZero;
}

- (void)setScrollViewContentInset:(UIEdgeInsets)insets
{
    objc_setAssociatedObject(self, &kScrollViewContentInsetKey, [NSValue valueWithUIEdgeInsets:insets], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)addObserverForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObserverForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    UIScrollView *scrollView = [self scrollViewForKeyboardNotifications];
    if (!scrollView) return;

    NSDictionary *userInfo = [notification userInfo];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    CGRect keyboardEndFrameInScreen = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardEndFrameInWindow = [window convertRect:keyboardEndFrameInScreen fromWindow:nil];
    CGRect keyboardEndFrameInView = [self.view convertRect:keyboardEndFrameInWindow fromView:nil];
    CGFloat heightCoveredWithKeyboard = CGRectGetMaxY(scrollView.frame) - CGRectGetMinY(keyboardEndFrameInView);

    UIEdgeInsets insets = [self scrollViewContentInset];
    insets.bottom = heightCoveredWithKeyboard;
    [self scrollView:scrollView setInsets:insets givenUserInfo:userInfo];

    if ([scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)scrollView;
        NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
        if (indexPath) {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIScrollView *scrollView = [self scrollViewForKeyboardNotifications];
    if (scrollView) {
        UIEdgeInsets insets = [self scrollViewContentInset];
        [self scrollView:scrollView setInsets:insets givenUserInfo:notification.userInfo];
    }
}

- (void)scrollView:(UIScrollView *)scrollView setInsets:(UIEdgeInsets)insets givenUserInfo:(NSDictionary *)userInfo
{
    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    UIViewAnimationOptions animationOptions = (animationCurve << 16);
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptions
                     animations:^{
                         scrollView.contentInset = insets;
                         scrollView.scrollIndicatorInsets = insets;
                     }
                     completion:nil];
}

@end
