//
//  NWViewController.h
//  Task
//
//  Created by Nicholas Wargnier on 11/4/13.
//  Copyright (c) 2013 Nicholas Wargnier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWAddTaskViewController.h"
#import "NWDetailTaskViewController.h"

@interface NWViewController : UIViewController < NWAddTaskViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, NWDetailViewControllerDelegate >

@property (strong, nonatomic) NSMutableArray *taskObjects;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)reorderBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)addTaskBarButtonItemPressed:(UIBarButtonItem *)sender;
@end
