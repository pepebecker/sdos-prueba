//
//  AppDelegate.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 04/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasLaunchedOnce"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /***********************************************************************************/
    // Check if the app was lauched for the first time
    // If so then copy the json files from the main bundle to the documents folder
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Load users.json from main bundle and save contents into an array of users
        NSArray *users = [JSONManager loadJSONArrayFromMainBundle:@"users" withKey:@"users"];
        
        // Save array of users to users.json in the documents folder
        [JSONManager writeArray:users toJSONFile:@"users" withkey:@"users"];
        
        // Load tasks.json from main bundle and save contents into an array of tasks
        NSArray *tasks = [JSONManager loadJSONArrayFromMainBundle:@"tasks" withKey:@"tasks"];
        
        // Save array of tasks to tasks.json in the documents folder
        [JSONManager writeArray:tasks toJSONFile:@"tasks" withkey:@"tasks"];
        
        // Set the lastTaskID to the total count of existing tasks to be able to create new tasks
        NSNumber *lastTaskID = [NSNumber numberWithUnsignedInteger:tasks.count];
        [[NSUserDefaults standardUserDefaults] setObject:lastTaskID forKey:@"lastTaskID"];
    }
    /***********************************************************************************/
    
    return YES;
}

@end
