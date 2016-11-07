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

-(IBAction)prepareForSignOut:(UIStoryboardSegue *)segue
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user"];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add a padding of 20px to the left of both textfields.
    [self.usernameField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)]];
    [self.passwordField setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)]];
    [self.usernameField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];
    
    // Add a target to both textfields to be able to determine if the value has change.
    // This way to can enable / disable the sign in button depending on the content of the textfield.
    [self.usernameField addTarget:self action:@selector(textFieldValueChanged) forControlEvents:UIControlEventEditingChanged];
    [self.passwordField addTarget:self action:@selector(textFieldValueChanged) forControlEvents:UIControlEventEditingChanged];
    
    // Set the delegate of both textfields to this view controller to be able to determine if the value of a textfield has changed.
    [self.usernameField setDelegate:self];
    [self.passwordField setDelegate:self];
    
    // Disable the sign in button.
    [self.signinButton setEnabled:NO];
    [self.signinButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Load the user from standardUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    
    // If the user exist show the corresponding view
    if (user)
    {
        NSString *segueID = @"showAdminVC";
        if ([user[@"type"] isEqualToString:@"technician"])
        {
            segueID = @"showTechnicianVC";
        }
        [self performSegueWithIdentifier:segueID sender:self];
    }
    // If the user does not exist load all users from the json file
    // and add a target to the signin button to be able to interact with it
    else
    {
        self.users = [JSONManager loadJSONArrayFromDocuments:@"users" withKey:@"users"];
        [self.signinButton addTarget:self action:@selector(attemptToSignIn) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    // When the view disappears remove the content of both textfields
    // and disable the signin button for the next login.
    [super viewDidDisappear:animated];
    [self.usernameField setText:@""];
    [self.passwordField setText:@""];
    [self.signinButton setEnabled:NO];
}

- (void)textFieldValueChanged
{
    if ([self.usernameField.text length] > 0 && [self.passwordField.text length] > 0)
    {
        // If both textfields are not empty enable the sign in button.
        [self.signinButton setEnabled:YES];
    }
    else
    {
        // If at least one of both texfields is empty disable the sign in button.
        [self.signinButton setEnabled:NO];
    }
}

- (void)attemptToSignIn
{
    // When the user presses the signin button attempt to sign in with the username and password from the textfields
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    [self signInWithUsername:username andPassword:password];
}

- (void)signInWithUsername:(NSString*)username andPassword:(NSString*)password
{
    BOOL canSignIn = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (NSDictionary *user in self.users)
    {
        if ([username isEqualToString:user[@"username"]] && [password isEqualToString:user[@"password"]])
        {
            canSignIn = YES;
            [defaults setObject:user forKey:@"user"];
        }
    }
    
    if (canSignIn)
    {
        NSLog(@"Successfully signed in!");
        
        NSString *type = [defaults objectForKey:@"user"][@"type"];
        
        NSString *segueID = @"showAdminVC";
        if ([type isEqualToString:@"technician"])
        {
            segueID = @"showTechnicianVC";
        }
        [self performSegueWithIdentifier:segueID sender:self];
    }
    else
    {
        NSLog(@"Could not sign in!");
        
        NSString *title = @"Por favor, intenta de nuevo...";
        NSString *message = @"La ID de usario y contraseña introducidos no coinciden con nuestros registros. Revísalos y inténtalo de nuevo.";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Aceptar" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameField])
    {
        [self.passwordField becomeFirstResponder];
    }
    if ([textField isEqual:self.passwordField])
    {
        [self attemptToSignIn];
    }
    return YES;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

@end
