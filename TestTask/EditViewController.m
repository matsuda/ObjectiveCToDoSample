//
//  EditViewController.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "EditViewController.h"
#import "TextFieldCell.h"
#import "TextViewCell.h"
#import "Task.h"
#import "KeyboardAccessoryView.h"
#import "PickerController.h"
#import "DatePickerController.h"
#import "KeyboardAccessoryView.h"

static NSString *TextFieldCellIdentifier = @"TextFieldCell";
static NSString *TextViewCellIdentifier = @"TextViewCell";

@interface EditViewController () <
    UITableViewDataSource, UITableViewDelegate,
    UITextFieldDelegate, UITextViewDelegate,
    UIPickerViewDataSource, UIPickerViewDelegate,
    PickerControllerDelegate, DatePickerControllerDelegate,
    KeyboardAccessoryViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSValue *scrollViewContentInset;
@property (strong, nonatomic) KeyboardAccessoryView *accessoryView;
@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.presentingViewController) {
        self.title = @"ToDo作成";
    } else {
        self.title = @"ToDo編集";
    }
    [self prepareTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addObserverForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObserverForKeyboardNotifications];
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

#pragma mark - inputAccessoryView

- (UIView *)inputAccessoryView
{
    return self.accessoryView;
}

- (KeyboardAccessoryView *)accessoryView
{
    if (!_accessoryView) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([KeyboardAccessoryView class]) bundle:nil];
        KeyboardAccessoryView *view = [[nib instantiateWithOwner:nil options:nil] firstObject];
        view.delegate = self;
        _accessoryView = view;
    }
    return _accessoryView;
}

- (void)keyboardAccessoryView:(KeyboardAccessoryView *)view didTapDone:(UIBarButtonItem *)button
{
    [self.view endEditing:YES];
}

- (void)keyboardAccessoryView:(KeyboardAccessoryView *)view didTapClose:(UIBarButtonItem *)button
{
    [self.view endEditing:YES];
}

- (IBAction)tapSubmit:(id)sender {
    [self.view endEditing:YES];
    NSMutableArray *messages = [NSMutableArray array];
    if (![self.task.title length]) {
        [messages addObject:@"タイトルを入力してください。"];
    }
    if ([messages count] > 0) {
        NSString *message = [messages componentsJoinedByString:@"\n"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"入力エラー" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    [self.delegate editViewController:self didFinishWithSave:YES];
    [self dismiss];
}

- (IBAction)tapCancel:(id)sender {
    [self.view endEditing:YES];
    [self.delegate editViewController:self didFinishWithSave:NO];
    [self dismiss];
}

- (void)dismiss
{
    if (self.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)prepareTableView
{
    self.tableView.rowHeight = 44;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TextFieldCell class]) bundle:nil] forCellReuseIdentifier:TextFieldCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TextViewCell class]) bundle:nil] forCellReuseIdentifier:TextViewCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    switch (indexPath.row) {
        case TaskPropertyMemo:
            height = 180;
            break;
        default:
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case TaskPropertyTitle:
            cell = [self tableView:tableView textFieldCellForRowAtIndexPath:indexPath];
            break;
        case TaskPropertyMemo:
            cell = [self tableView:tableView textViewCellForRowAtIndexPath:indexPath];
            break;
        default:
            cell = [self tableView:tableView defaultCellForRowAtIndexPath:indexPath];
            break;
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView defaultCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView textFieldCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:TextFieldCellIdentifier];
    cell.textField.delegate = self;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView textViewCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextViewCell *cell = (TextViewCell *)[tableView dequeueReusableCellWithIdentifier:TextViewCellIdentifier];
    cell.textView.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TaskPropertyTitle: {
            TextFieldCell *cell = (TextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.textField becomeFirstResponder];
            break;
        }
        case TaskPropertyMemo: {
            TextViewCell *cell = (TextViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.textView becomeFirstResponder];
            break;
        }
        case TaskPropertyPriority:
            [self presentPickerController];
            break;
        case TaskPropertyDueDate:
            [self presentDatePickerController];
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TaskPropertyTitle: {
            TextFieldCell *editCell = (TextFieldCell *)cell;
            editCell.textField.placeholder = @"入力";
            editCell.label.text = TaskPropertyString(indexPath.row);
            editCell.textField.text = self.task.title;
            break;
        }
        case TaskPropertyMemo: {
            TextViewCell *editCell = (TextViewCell *)cell;
            editCell.label.font = [UIFont systemFontOfSize:17];
            editCell.label.text = TaskPropertyString(indexPath.row);
            editCell.textView.text = self.task.memo;
            break;
        }
        case TaskPropertyPriority: {
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = TaskPropertyString(indexPath.row);
            cell.detailTextLabel.text = TaskPriorityString(self.task.priority);
            break;
        }
        case TaskPropertyDueDate: {
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.textLabel.text = TaskPropertyString(indexPath.row);
            cell.detailTextLabel.text = [self.task dueDateAsString];
            break;
        }
        default:
            break;
    }
}

- (void)selectRowAtFirstRespondingView:(UIView *)current
{
    NSIndexPath *indexPath = [self indexPathAtFirstRespondingView:current];
    if (indexPath) {
        [self flashRowAtIndexPath:indexPath];
    }
}

- (NSIndexPath *)indexPathAtFirstRespondingView:(UIView *)current
{
    UIView *view = current.superview;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    if ([view isKindOfClass:[UITableViewCell class]]) {
        return [self.tableView indexPathForCell:(UITableViewCell *)view];
    }
    return nil;
}

- (void)flashRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    static CGFloat delay = 0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

- (void)assignText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case TaskPropertyTitle:
            self.task.title = text;
            break;
        case TaskPropertyMemo:
            self.task.memo = text;
            break;
    }
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathAtFirstRespondingView:textField];
    if (indexPath) {
        [self flashRowAtIndexPath:indexPath];
    }
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathAtFirstRespondingView:textField];
    if (indexPath) {
        [self assignText:textField.text atIndexPath:indexPath];
    }
}

#pragma mark - UITextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSIndexPath *indexPath = [self indexPathAtFirstRespondingView:textView];
    if (indexPath) {
        [self flashRowAtIndexPath:indexPath];
    }
    return true;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSIndexPath *indexPath = [self indexPathAtFirstRespondingView:textView];
    if (indexPath) {
        [self assignText:textView.text atIndexPath:indexPath];
    }
}


#pragma mark - Keyboard

- (NSValue *)scrollViewContentInset
{
    if (!_scrollViewContentInset) {
        _scrollViewContentInset = [NSValue valueWithUIEdgeInsets:self.tableView.contentInset];
    }
    return _scrollViewContentInset;
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
    NSDictionary *userInfo = [notification userInfo];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    CGRect keyboardEndFrameInScreen = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardEndFrameInWindow = [window convertRect:keyboardEndFrameInScreen fromWindow:nil];
    CGRect keyboardEndFrameInView = [self.view convertRect:keyboardEndFrameInWindow fromView:nil];
    CGFloat heightCoveredWithKeyboard = CGRectGetMaxY(self.tableView.frame) - CGRectGetMinY(keyboardEndFrameInView);

    UIEdgeInsets insets = [[self scrollViewContentInset] UIEdgeInsetsValue];
    insets.bottom = heightCoveredWithKeyboard;
    [self scrollView:self.tableView setInsets:insets givenUserInfo:userInfo];

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets insets = [[self scrollViewContentInset] UIEdgeInsetsValue];
    [self scrollView:self.tableView setInsets:insets givenUserInfo:notification.userInfo];
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

#pragma mark - PickerController

- (void)presentPickerController
{
    [self.view endEditing:YES];

    PickerController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PickerController"];
    __weak typeof(self) wself = self;
    [controller presentPickerWithAnimated:YES completion:^(BOOL finished) {
        TaskPriority priority = wself.task.priority;
        [controller.pickerView selectRow:priority+1 inComponent:0 animated:YES];
    }];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    controller.delegate = self;
    controller.pickerView.delegate = self;
    controller.pickerView.dataSource = self;
}

- (void)dismissPickerController:(PickerController *)controller
{
    [controller dismissPickerWithAnimated:YES completion:^(BOOL finished) {
        [controller willMoveToParentViewController:nil];
        [controller removeFromParentViewController];
    }];
}

- (void)pickerControllerDidCancel:(PickerController *)controller
{
    [self dismissPickerController:controller];
}

- (void)pickerControllerDidSelect:(PickerController *)controller
{
    NSInteger index = [controller.pickerView selectedRowInComponent:0];
    [self dismissPickerController:controller];

    self.task.priority = index - 1;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:TaskPropertyPriority inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    TaskPriority priority = row - 1;
    return TaskPriorityString(priority);
}

#pragma mark - DatePickerController

- (void)presentDatePickerController
{
    [self.view endEditing:YES];

    DatePickerController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DatePickerController"];
    __weak typeof(self) wself = self;
    [controller presentPickerWithAnimated:YES completion:^(BOOL finished) {
        controller.datePicker.date = wself.task.dueDate;
    }];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    controller.delegate = self;
}

- (void)dismissDatePickerController:(DatePickerController *)controller
{
    [controller dismissPickerWithAnimated:YES completion:^(BOOL finished) {
        [controller willMoveToParentViewController:nil];
        [controller removeFromParentViewController];
    }];
}

- (void)datePickerControllerDidCancel:(DatePickerController *)controller
{
    [self dismissDatePickerController:controller];
}

- (void)datePickerControllerDidSelect:(DatePickerController *)controller
{
    NSDate *date = controller.datePicker.date;
    [self dismissDatePickerController:controller];

    self.task.dueDate = date;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:TaskPropertyDueDate inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
