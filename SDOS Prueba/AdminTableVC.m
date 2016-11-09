//
//  AdminVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 04/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "AdminTableVC.h"

@interface AdminTableVC ()
{
    BOOL didCreateNewTask;
}

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) UIImage *doneImage;

@end

@implementation AdminTableVC

-(IBAction)prepareForCancelNewTask:(UIStoryboardSegue *)segue
{
    NSLog(@"Cancel new task");
}

-(IBAction)prepareForAdminDeleteTask:(UIStoryboardSegue *)segue
{
    NSLog(@"Delete task");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *task = [defaults objectForKey:@"task"];
    NSInteger taskIndex = [[defaults objectForKey:@"taskIndex"] intValue];
    
    [self.tasks removeObject:task];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:taskIndex inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [JSONManager writeArray:self.tasks toJSONFile:@"tasks" withkey:@"tasks"];
}

-(IBAction)prepareForSaveNewTask:(UIStoryboardSegue *)segue
{
    NSLog(@"Saving new task");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *task = [defaults objectForKey:@"task"];
    
    [self.tasks insertObject:task atIndex:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    
    [JSONManager writeArray:self.tasks toJSONFile:@"tasks" withkey:@"tasks"];

    [defaults setInteger:indexPath.row forKey:@"taskIndex"];
    [defaults synchronize];
    
    didCreateNewTask = YES;
}

-(IBAction)prepareForUpdateTask:(UIStoryboardSegue *)segue
{
    NSLog(@"Updating task");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *task = [defaults objectForKey:@"task"];
    NSInteger taskIndex = [defaults integerForKey:@"taskIndex"];
    
    [self.tasks replaceObjectAtIndex:taskIndex withObject:task];
    
    [defaults removeObjectForKey:@"task"];
    [defaults removeObjectForKey:@"taskIndex"];
    [defaults synchronize];
    
    [JSONManager writeArray:self.tasks toJSONFile:@"tasks" withkey:@"tasks"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.doneImage = [UIImage imageNamed:@"done"];
    self.tasks = [[NSMutableArray alloc] initWithArray:[JSONManager loadJSONArrayFromDocuments:@"tasks" withKey:@"tasks"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (didCreateNewTask) {
        [self performSegueWithIdentifier:@"showUserSelection" sender:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    didCreateNewTask = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MGSwipeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"taskCell"];
    cell.delegate = self;
    
    NSDictionary *task = [self.tasks objectAtIndex:indexPath.row];
    
    cell.textLabel.text = task[@"title"];
    
    BOOL completed = [[task valueForKey:@"completed"] isEqual:@1];
    
    if (completed)
    {
        cell.detailTextLabel.text = @"";
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.doneImage];
    }
    else
    {
        int hours = [task[@"hours"] intValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d h", hours];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"Eliminar" backgroundColor:[UIColor redColor]];
    
    cell.rightButtons = @[deleteButton];
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.fillOnTrigger = TRUE;
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
    
    MGSwipeButton *infoButton = [MGSwipeButton buttonWithTitle:@"Detalles" backgroundColor:self.view.tintColor];
    
    cell.leftButtons = @[infoButton];
    cell.leftExpansion.buttonIndex = 0;
    cell.leftExpansion.fillOnTrigger = TRUE;
    cell.leftSwipeSettings.transition = MGSwipeTransitionDrag;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *task = [self.tasks objectAtIndex:indexPath.row];
    BOOL completed = [[task valueForKey:@"completed"] isEqual:@1];
    
    if (completed)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.tasks[indexPath.row] forKey:@"task"];
    [defaults setInteger:indexPath.row forKey:@"taskIndex"];
    [defaults synchronize];
    
    [self performSegueWithIdentifier:@"showUserSelection" sender:self];
}

#pragma mark - GMSwipeTableCell

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    if (direction == MGSwipeDirectionRightToLeft)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tasks removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [JSONManager writeArray:self.tasks toJSONFile:@"tasks" withkey:@"tasks"];
    }
    
    if (direction == MGSwipeDirectionLeftToRight)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.tasks[indexPath.row] forKey:@"task"];
        [defaults setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"taskIndex"];
        [defaults synchronize];
        
        [self performSegueWithIdentifier:@"showTask" sender:self];
    }
    
    return YES;
}

@end
