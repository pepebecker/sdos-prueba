//
//  TechnicianTableVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "TechnicianTableVC.h"

@interface TechnicianTableVC ()

@property (nonatomic, strong) NSMutableDictionary *user;
@property (nonatomic, strong) NSMutableArray *allTasks;
@property (nonatomic, strong) NSMutableArray *myTasks;
@property (nonatomic, strong) UIImage *inprogressImage;
@property (nonatomic, strong) UIImage *doneImage;

@end

@implementation TechnicianTableVC

-(IBAction)prepareForDeletedTask:(UIStoryboardSegue *)segue
{
    [self deleteTask];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    self.allTasks = [[NSMutableArray alloc] init];
    self.myTasks = [[NSMutableArray alloc] init];
    
    self.inprogressImage = [UIImage imageNamed:@"inprogress"];
    self.doneImage = [UIImage imageNamed:@"done"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.myTasks removeAllObjects];
    
    NSArray *loadedTasks = [JSONManager loadJSONArrayFromDocuments:@"tasks" withKey:@"tasks"];
    self.allTasks = [NSMutableArray arrayWithArray:loadedTasks];
    
    for (NSDictionary *task in loadedTasks) {
        NSArray *techniciansWorkingOnTask = [task objectForKey:@"technicians"];
        if ([techniciansWorkingOnTask containsObject:[self.user objectForKey:@"id"]]) {
            [self.myTasks addObject:task];
        }
    }
    
    [self.tableView reloadData];
}

- (NSArray*)replaceTaskInList:(NSArray*)tasks withTask:(NSDictionary*)task
{
    NSMutableArray *newTasks = [[NSMutableArray alloc] initWithArray:tasks];
    
    for (int i = 0; i < tasks.count; i++)
    {
        NSDictionary *t = [tasks objectAtIndex:i];
        if ([[t objectForKey:@"id"] isEqual:[task objectForKey:@"id"]])
        {
            [newTasks replaceObjectAtIndex:i withObject:task];
            break;
        }
    }
    
    return newTasks;
}

- (void)deleteTask
{
    NSLog(@"Deleted task");
    
    NSDictionary *task = [[NSUserDefaults standardUserDefaults] objectForKey:@"task"];
    
    self.allTasks = [NSMutableArray arrayWithArray:[self replaceTaskInList:self.allTasks withTask:task]];
    
    [JSONManager writeArray:self.allTasks toJSONFile:@"tasks" withkey:@"tasks"];
    
    [self.myTasks removeAllObjects];
    
    for (NSDictionary *task in self.allTasks) {
        NSArray *techniciansWorkingOnTask = [task objectForKey:@"technicians"];
        if ([techniciansWorkingOnTask containsObject:[self.user objectForKey:@"id"]]) {
            [self.myTasks addObject:task];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGSwipeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"taskCell"];
    cell.delegate = self;
    
    NSDictionary *task = [self.myTasks objectAtIndex:indexPath.row];
    
    cell.textLabel.text = task[@"title"];
    
    NSArray *techniciansWhoHaveStated = [task valueForKey:@"started"];
    BOOL started = [techniciansWhoHaveStated containsObject:[self.user objectForKey:@"id"]];
    BOOL completed = [[task valueForKey:@"completed"] isEqual:@1];
    
    if (started && !completed)
    {
        cell.detailTextLabel.text = @"";
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.inprogressImage];
    }
    else if (completed)
    {
        cell.detailTextLabel.text = @"";
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.doneImage];
    }
    else
    {
        NSInteger hours = [task[@"hours"] intValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d h", hours];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"Eliminar" backgroundColor:[UIColor redColor]];
    
    cell.rightButtons = @[deleteButton];
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.fillOnTrigger = TRUE;
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *task = [self.myTasks objectAtIndex:indexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:task forKey:@"task"];
    [defaults synchronize];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"showTask" sender:self];
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    if (direction == MGSwipeDirectionRightToLeft)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        NSMutableDictionary *task = [[NSMutableDictionary alloc] initWithDictionary:self.myTasks[indexPath.row]];
        
        NSMutableArray *technicians = [[NSMutableArray alloc] initWithArray:[task objectForKey:@"technicians"]];
        NSMutableArray *started = [[NSMutableArray alloc] initWithArray:[task objectForKey:@"started"]];
        [technicians removeObject:[self.user objectForKey:@"id"]];
        [started removeObject:[self.user objectForKey:@"id"]];
        [task setObject:technicians forKey:@"technicians"];
        [task setObject:started forKey:@"started"];
        
        [[NSUserDefaults standardUserDefaults] setObject:task forKey:@"task"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self deleteTask];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    return YES;
}

@end
