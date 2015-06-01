//
//  DatePickerController.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "DatePickerController.h"

@interface DatePickerController ()

@property (weak, nonatomic) IBOutlet UIView *grandView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerViewBottomConstraint;
@end

@implementation DatePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];

    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"ja_JP"];
    self.datePicker.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"JST"];

    self.grandView.backgroundColor = [UIColor blackColor];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGrand:)];
    [self.grandView addGestureRecognizer:gesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapDone:(id)sender {
    if ([self.delegate respondsToSelector:@selector(datePickerControllerDidSelect:)]) {
        [self.delegate datePickerControllerDidSelect:self];
    }
}

- (IBAction)tapCancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(datePickerControllerDidCancel:)]) {
        [self.delegate datePickerControllerDidCancel:self];
    }
}

- (void)tapGrand:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(datePickerControllerDidCancel:)]) {
        [self.delegate datePickerControllerDidCancel:self];
    }
}

- (void)presentPickerWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (self.view.superview) return;

    self.grandView.alpha = 0;
    CGRect frame = [UIScreen mainScreen].bounds;
    self.view.frame = frame;

    NSEnumerator *windows = [[UIApplication sharedApplication].windows reverseObjectEnumerator];
    for (UIWindow *window in windows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self.view];
            break;
        }
    }

    CGFloat height = CGRectGetHeight(self.toolbar.frame) + CGRectGetHeight(self.datePicker.frame);
    CGRect endFrame = self.datePicker.frame;
    CGRect startFrame = endFrame;
    startFrame.origin.y += height;
    self.datePicker.frame = startFrame;

    CGRect endFrameToolbar = self.toolbar.frame;
    CGRect startFrameToolbar = endFrameToolbar;
    startFrameToolbar.origin.y += height;
    self.toolbar.frame = startFrameToolbar;

    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews) animations:^{
        wself.grandView.alpha = 0.5;
        wself.datePicker.frame = endFrame;
        wself.toolbar.frame = endFrameToolbar;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)dismissPickerWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    if (self.view.superview == nil) return;

    self.datePickerViewBottomConstraint.constant = -260;
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.2 delay:0 options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews) animations:^{
        wself.grandView.alpha = 0;
        [wself.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [wself.view removeFromSuperview];
        if (completion) {
            completion(finished);
        }
    }];
}

@end
