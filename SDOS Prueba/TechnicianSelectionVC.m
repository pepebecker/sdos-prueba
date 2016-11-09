//
//  TechnicianSelectionVC.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "TechnicianSelectionVC.h"

@interface TechnicianSelectionVC ()
@property (nonatomic, strong) NSMutableDictionary *task;
@property (nonatomic, strong) NSMutableArray *technicians;
@property (nonatomic, strong) NSMutableArray *selectedTechinicians;
@property (nonatomic, strong) UIImage *inprogressImage;

// Only select one technician
@property (nonatomic, strong) NSMutableDictionary *lastTechnician;
@property (nonatomic, strong) UITableViewCell *lastTechnicianCell;
@property (nonatomic, strong) NSIndexPath *lastTechnicianIndex;

@end

@implementation TechnicianSelectionVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inprogressImage = [UIImage imageNamed:@"inprogress"];
    
    UIBarButtonSystemItem style = UIBarButtonSystemItemSave;
    SEL selector = @selector(saveSelection);
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:style target:self action:selector];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Task
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.task = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"task"]];
    
    self.selectedTechinicians = [[NSMutableArray alloc] initWithArray:[self.task objectForKey:@"technicians"]];
    
    // Technician
    NSArray *users = [JSONManager loadJSONArrayFromDocuments:@"users" withKey:@"users"];
    NSArray *tasks = [JSONManager loadJSONArrayFromDocuments:@"tasks" withKey:@"tasks"];
    
    self.technicians = [[NSMutableArray alloc] init];
    
    BOOL started = [self.task[@"started"] count] > 0;
    
    if (started)
    {
        for (NSDictionary *user in users)
        {
            if ([self.task[@"technicians"] containsObject:user[@"id"]])
            {
                [self.technicians addObject:user];
            }
        }
    }
    else
    {
        for (NSDictionary *user in users)
        {
            if ([user[@"type"] isEqualToString:@"technician"])
            {
                if ([user[@"field"] isEqualToString:self.task[@"type"]])
                {
                    NSMutableDictionary *newUser = [[NSMutableDictionary alloc] initWithDictionary:user];
                    
                    NSInteger hours = 0;
                    
                    for (NSDictionary *task in tasks)
                    {
                        if ([task[@"technicians"] containsObject:user[@"id"]])
                        {
                            hours += [task[@"hours"] intValue];
                        }
                    }
                    
                    [newUser setObject:[NSNumber numberWithInteger:hours] forKey:@"hours"];
                    
                    [self.technicians addObject:newUser];
                }
            }
        }
    }
}

-(void)saveSelection
{
    [self.task setObject:self.selectedTechinicians forKey:@"technicians"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.task forKey:@"task"];
    [defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self performSegueWithIdentifier:@"updateTask" sender:self];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.technicians.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"technicianCell" forIndexPath:indexPath];
    
    NSMutableDictionary *technician = self.technicians[indexPath.row];
    NSString *tecName = [technician objectForKey:@"name"];
    NSNumber *tecID = [technician objectForKey:@"id"];
    
    cell.textLabel.text = tecName;
    
    if ([self.selectedTechinicians containsObject:tecID])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if (self.lastTechnicianCell == NULL) {
            self.lastTechnician = technician;
            self.lastTechnicianCell = cell;
            self.lastTechnicianIndex = indexPath;
        }
    }
    
    BOOL started = [[self.task objectForKey:@"started"] containsObject:tecID];
    
    if (started)
    {
        cell.detailTextLabel.text = @"";
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.inprogressImage];
        cell.userInteractionEnabled = NO;
    }
    else
    {
        int hours = [technician[@"hours"] intValue];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d h", hours];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSMutableDictionary *technician = self.technicians[indexPath.row];
    NSNumber *tecID = technician[@"id"];
    
//    if ([self.task[@"started"] count] > 0) {
//        return;
//    }
    
    if (self.lastTechnician && ![self.lastTechnician[@"id"] isEqual:tecID])
    {
        [self.selectedTechinicians removeObject:self.lastTechnician[@"id"]];
        
        int tecHours = [self.lastTechnician[@"hours"] intValue];
        int taskHours = [self.task[@"hours"] intValue];
        
        tecHours -= taskHours;
        
        self.lastTechnician[@"hours"] = [NSNumber numberWithInteger:tecHours];
        self.lastTechnicianCell.detailTextLabel.text = [NSString stringWithFormat:@"%d h", tecHours];
        
        self.lastTechnicianCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    int tecHours = [technician[@"hours"] intValue];
    int taskHours = [self.task[@"hours"] intValue];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedTechinicians removeObject:tecID];
        
        tecHours -= taskHours;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedTechinicians addObject:tecID];
        
        tecHours += taskHours;
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d h", tecHours];
    
    technician[@"hours"] = [NSNumber numberWithInt:tecHours];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.lastTechnician && [self.lastTechnician[@"id"] isEqual:tecID]) {
        self.lastTechnician = NULL;
        self.lastTechnicianCell = NULL;
        self.lastTechnicianIndex = NULL;
    }
    else
    {
        self.lastTechnician = technician;
        self.lastTechnicianCell = cell;
        self.lastTechnicianIndex = indexPath;
    }
}

@end
