//
//  MasterViewController.m
//  TestTask
//
//  Created by Kosuke Matsuda on 2015/06/01.
//  Copyright (c) 2015年 matsuda. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "EditViewController.h"
#import "Task.h"
#import "Task+Mock.h"

@interface MasterViewController () <EditViewControllerDelegate>
@property NSMutableArray *dataSource;
@property (strong, nonatomic) UIBarButtonItem *addBarButton;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.dataSource = [[Task findAll] mutableCopy];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateTask:) name:DidUpdateTaskNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    /*
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
     */
    [super viewWillAppear:animated];
    if ([self.dataSource count] > 0) {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidUpdateTaskNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Task *task = self.dataSource[indexPath.row];
        DetailViewController *destination = (DetailViewController *)segue.destinationViewController;
        destination.task = task;
    }
    if ([segue.identifier isEqualToString:@"createTask"]) {
        UINavigationController *navi = (UINavigationController *)segue.destinationViewController;
        EditViewController *c = (EditViewController *)[navi.viewControllers firstObject];
        c.task = [Task new];
        c.delegate = self;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing) {
        self.addBarButton = self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.addBarButton;
        self.addBarButton = nil;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Task *task = self.dataSource[indexPath.row];
    cell.textLabel.text = task.title;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *task = self.dataSource[indexPath.row];
        if (![task delete]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"削除エラー" message:@"削除できませんでした。" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark -

- (void)editViewController:(EditViewController *)controller didFinishSaveWithTask:(Task *)task
{
    NSLog(@"%s saved task >>> %@", __PRETTY_FUNCTION__, task);
    if (!task) return;

//    [self.tableView beginUpdates];
    [self.dataSource insertObject:task atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
}

- (void)didUpdateTask:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    Task *task = userInfo[UpdatedTaskKey];
    NSLog(@"%s updated task >>> %@", __PRETTY_FUNCTION__, task);
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (!indexPath) return;

    [self.dataSource replaceObjectAtIndex:indexPath.row withObject:task];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
