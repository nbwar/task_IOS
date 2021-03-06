//
//  NWViewController.m
//  Task
//
//  Created by Nicholas Wargnier on 11/4/13.
//  Copyright (c) 2013 Nicholas Wargnier. All rights reserved.
//

#import "NWViewController.h"

@interface NWViewController ()

@end

@implementation NWViewController

-(NSMutableArray *)taskObjects
{
    if (!_taskObjects) _taskObjects = [[NSMutableArray alloc] init];
    return _taskObjects;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // conform to tableview data source protocol & delegate
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    NSArray *tasksAsPropertyLists = [[NSUserDefaults standardUserDefaults] arrayForKey:TASK_OBJECTS_KEY];
    
    for (NSDictionary *dictionary in tasksAsPropertyLists) {
        NWTask *taskObject = [self taskObjectForDictioanry:dictionary];
        [self.taskObjects addObject:taskObject];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[NWAddTaskViewController class]]) {
        NWAddTaskViewController *addTaskVC = segue.destinationViewController;
        addTaskVC.delegate = self;
    } else if ([segue.destinationViewController isKindOfClass:[NWDetailTaskViewController class]]) {
        NWDetailTaskViewController *detailTaskVC = segue.destinationViewController;
        
        NSIndexPath *path = sender;
        NWTask *task = self.taskObjects[path.row];
        detailTaskVC.task = task;
        detailTaskVC.delegate = self;
    }
}

#pragma mark - IBActions

- (IBAction)reorderBarButtonItemPressed:(UIBarButtonItem *)sender
{
    if (self.tableView.editing == YES) {
        [self.tableView setEditing:NO animated:YES];
    } else {
        [self.tableView setEditing:YES animated:YES];
    }
    
    // for this to work need 2 UITABLEIVIEW delegate methods
}

- (IBAction)addTaskBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"toAddTaskViewControllerSegue" sender:nil];
}

#pragma mark - NWAddTaskViewControllerDelegate

-(void)didAddTask:(NWTask *)task
{
    [self.taskObjects addObject:task];
    NSMutableArray *taskObjectsAsPropertyLists = [[[NSUserDefaults standardUserDefaults] arrayForKey:TASK_OBJECTS_KEY] mutableCopy];
    if (!taskObjectsAsPropertyLists) taskObjectsAsPropertyLists = [[NSMutableArray alloc] init];
    
    [taskObjectsAsPropertyLists addObject:[self taskObjectAsPropertyList:task]];
    
    [[NSUserDefaults standardUserDefaults] setObject:taskObjectsAsPropertyLists forKey:TASK_OBJECTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

-(void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper Methods

-(NSDictionary *)taskObjectAsPropertyList:(NWTask *)task
{
    NSDictionary *dictionary = @{TASK_TITLE : task.title, TASK_DESCRIPTION : task.description, TASK_DATE : task.date, TASK_COMPLETION : @(task.isCompleted)};
    
    return dictionary;
}

-(NWTask *)taskObjectForDictioanry:(NSDictionary *)dictionary
{
    NWTask *taskObject = [[NWTask alloc] initWithData:dictionary];
    return taskObject;
}


-(BOOL)isDateGreaterThanDate:(NSDate *)date and:(NSDate *)toDate
{
    NSTimeInterval dateInterval = [date timeIntervalSinceReferenceDate];
    NSTimeInterval toDateInterval = [toDate timeIntervalSinceReferenceDate];
    
    if (dateInterval > toDateInterval) {
        return YES;
    } else {
        return NO;
    }
}


-(void)updateCompletionOfTask:(NWTask *)task forIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *taskObjectsAsPropertyList = [[[NSUserDefaults standardUserDefaults] arrayForKey:TASK_OBJECTS_KEY] mutableCopy];
    
    if (!taskObjectsAsPropertyList) taskObjectsAsPropertyList = [[NSMutableArray alloc] init];
    
    [taskObjectsAsPropertyList removeObjectAtIndex:indexPath.row];
    
    if (task.isCompleted == YES) task.isCompleted = NO;
    else task.isCompleted = YES;
    [taskObjectsAsPropertyList insertObject:[self taskObjectAsPropertyList:task] atIndex:indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setObject:taskObjectsAsPropertyList forKey:TASK_OBJECTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
}

-(void)saveTasks
{
    NSMutableArray *taskObjectsAsPropertyLists = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < [self.taskObjects count]; x++) {
        [taskObjectsAsPropertyLists addObject:[self taskObjectAsPropertyList:self.taskObjects[x]]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:taskObjectsAsPropertyLists forKey:TASK_OBJECTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.taskObjects count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // identifer set in storyboard
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure cell
    
    NWTask *task = self.taskObjects[indexPath.row];
    cell.textLabel.text = task.title;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatter stringFromDate:task.date];
    cell.detailTextLabel.text = stringFromDate;
    
    BOOL isOverDue = [self isDateGreaterThanDate:[NSDate date] and:task.date];
    if (task.isCompleted) cell.backgroundColor = [UIColor greenColor];
    else if (isOverDue) cell.backgroundColor = [UIColor redColor];
    else cell.backgroundColor = [UIColor yellowColor];
    
    return cell;
}


#pragma mark - UITableViewDelegate


// Tapping on cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NWTask *task = self.taskObjects[indexPath.row];
    [self updateCompletionOfTask:task forIndexPath:indexPath];
    
}

// To be able to swipe to delete

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.taskObjects removeObjectAtIndex:indexPath.row];
        NSMutableArray *newTaskObjectsData = [[NSMutableArray alloc] init];
        
        for (NWTask *task in self.taskObjects) {
            [newTaskObjectsData addObject:[self taskObjectAsPropertyList:task]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:newTaskObjectsData forKey:TASK_OBJECTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


// Accessory button Pressed
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toDetailTaskViewControllerSegue" sender:indexPath];
}


// For reorder
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// For reorder

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NWTask *task = self.taskObjects[sourceIndexPath.row];
    [self.taskObjects removeObjectAtIndex:sourceIndexPath.row];
    [self.taskObjects insertObject:task atIndex:destinationIndexPath.row];
    [self saveTasks];
}

#pragma mark - NWDetailTaskViewContorllerDelegate
-(void)updateTask
{
    [self saveTasks];
    [self.tableView reloadData];
}
@end
