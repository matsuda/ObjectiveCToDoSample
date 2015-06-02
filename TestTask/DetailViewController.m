//
//  DetailViewController.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "DetailViewController.h"
#import "EditViewController.h"
#import "Task.h"
#import "FlexibleLabelCell.h"

NSString * const DidUpdateTaskNotification = @"DidUpdateTaskNotification";
NSString * const UpdatedTaskKey = @"UpdatedTaskKey";

static NSString * MemoCellIdentifier = @"MemoCell";

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, EditViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FlexibleLabelCell *prototypeMemoCell;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setTask:(Task *)task
{
    if (_task != task) {
        _task = task;
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = self.task.title;
    [self prepareTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editTask"]) {
        EditViewController *destination = (EditViewController *)segue.destinationViewController;
        destination.task = self.task;
        destination.delegate = self;
    }
}

- (void)prepareTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FlexibleLabelCell class]) bundle:nil] forCellReuseIdentifier:MemoCellIdentifier];
}

- (void)layoutPrototypeCellInTableView:(UITableView *)tableView
{
    if (self.prototypeMemoCell) {
        CGRect frame = self.prototypeMemoCell.frame;
        frame.size.width = tableView.frame.size.width;
        self.prototypeMemoCell.frame = frame;
    }
    [self.prototypeMemoCell setNeedsLayout];
    [self.prototypeMemoCell layoutIfNeeded];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    switch (indexPath.row) {
        case TaskPropertyMemo: {
            if (self.prototypeMemoCell == nil) {
                self.prototypeMemoCell = (FlexibleLabelCell *)[tableView dequeueReusableCellWithIdentifier:MemoCellIdentifier];
            }
            [self configureMemoCell:self.prototypeMemoCell atIndexPath:indexPath];
            [self layoutPrototypeCellInTableView:tableView];
            CGSize size = [self.prototypeMemoCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            height = MAX(size.height + 1, height);
            break;
        }
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
        case TaskPropertyPriority:
        case TaskPropertyDueDate:
            cell = [self tableView:tableView labelCellForRowAtIndexPath:indexPath];
            break;
        case TaskPropertyMemo:
            cell = [self tableView:tableView memoCellForRowAtIndexPath:indexPath];
            break;
        default:
            cell = [self tableView:tableView defaultCellForRowAtIndexPath:indexPath];
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView defaultCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView labelCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LabelCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureLabelCell:cell atIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView memoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlexibleLabelCell *cell = (FlexibleLabelCell *)[tableView dequeueReusableCellWithIdentifier:MemoCellIdentifier];
    [self configureMemoCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureLabelCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = TaskPropertyString(indexPath.row);
    switch (indexPath.row) {
        case TaskPropertyTitle:
            cell.detailTextLabel.text = self.task.title;
            break;
        case TaskPropertyPriority:
            cell.detailTextLabel.text = TaskPriorityString(self.task.priority);
            break;
        case TaskPropertyDueDate:
            cell.detailTextLabel.text = [self.task dueDateAsString];
            break;
        default:
            break;
    }
}

- (void)configureMemoCell:(FlexibleLabelCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.contentLabel.font = [UIFont systemFontOfSize:15];
    cell.contentLabel.text = self.task.memo;
}

#pragma mark - 

- (void)editViewController:(EditViewController *)controller didFinishSaveWithTask:(Task *)task
{
    NSLog(@"%s saved task >>> %@", __PRETTY_FUNCTION__, task);
    if (!task) return;

    self.task = task;
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidUpdateTaskNotification
                                                        object:nil
                                                      userInfo:@{UpdatedTaskKey: task}];
}

@end
