//
//  CreateTaskVC.h
//  SDOS Prueba
//
//  Created by Pepe Becker on 05/11/2016.
//  Copyright © 2016 Pepe Becker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateTaskVC : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextField *typeField;
@property (strong, nonatomic) IBOutlet UITextField *durationField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionArea;

@end
