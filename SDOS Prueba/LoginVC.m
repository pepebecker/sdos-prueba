//
//  ViewController.m
//  SDOS Prueba
//
//  Created by Pepe Becker on 04/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@property (nonatomic, strong) NSArray* users;

@end

@implementation LoginVC

-(IBAction)prepareForSignOut:(UIStoryboardSegue *)segue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    
    if (user) {
        NSString *segueID = @"showAdminVC";
        if ([user[@"type"] isEqualToString:@"technician"]) {
            segueID = @"showTechnicianVC";
        }
        [self performSegueWithIdentifier:segueID sender:self];
    } else {
        self.users = [JSONManager loadJSONArrayFromDocuments:@"users" withKey:@"users"];
        [self.signinButton addTarget:self action:@selector(attemptToSignIn) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)attemptToSignIn {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    [self signInWithUsername:username andPassword:password];
}

- (void)signInWithUsername:(NSString*)username andPassword:(NSString*)password {
    NSLog(@"Signing In");
    
    BOOL canSignIn = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (NSDictionary *user in self.users) {
        if ([username isEqualToString:user[@"username"]] && [password isEqualToString:user[@"password"]]) {
            canSignIn = YES;
            [defaults setObject:user forKey:@"user"];
        }
    }
    
    if (canSignIn) {
        NSLog(@"Successfully signed in!");
        
        NSString *type = [defaults objectForKey:@"user"][@"type"];
        
        NSString *segueID = @"showAdminVC";
        if ([type isEqualToString:@"technician"]) {
            segueID = @"showTechnicianVC";
        }
        [self performSegueWithIdentifier:segueID sender:self];
    } else {
        NSLog(@"Could not sign in!");
    }
}

@end
