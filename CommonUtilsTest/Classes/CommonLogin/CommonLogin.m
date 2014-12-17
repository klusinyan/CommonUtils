//  Created by Karen Lusinyan on 11/09/14.

#import "CommonLogin.h"
#import "SFLoginCell.h"
#import "SFLoginTextFieldCell.h"
#import "SFLoginButtonCell.h"
#import "UITableView+Utils.h"

typedef NS_ENUM(NSInteger, SFLoginTextFiled) {
    SFLoginTextFiledUsername=1,
    SFLoginTextFiledPassowrd,
    SFLoginTextFiledFidelity
};

@interface CommonLogin ()
<
UITextFieldDelegate
>

@property (readwrite, nonatomic, strong) NSArray *cells;
@property (readwrite, nonatomic, getter=isLoading) BOOL loading;

@end

@implementation CommonLogin

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (SFLoginTextFieldCell *)fabriqueTextCellWithLabel:(NSString *)label
                                               text:(NSString *)text
                                    secureTextEntry:(BOOL)secureTextEntry
                                       placeHoolder:(NSString *)placeholder
                                                tag:(SFLoginTextFiled)tag
{
    SFLoginTextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSFLoginTextFieldCellIdentifier];
    cell.label.text = label;
    cell.textField.placeholder = placeholder;
    cell.textField.delegate = self;
    cell.textField.text = text;
    cell.textField.secureTextEntry = secureTextEntry;
    cell.textField.tag = tag;
    cell.userInteractionEnabled = !self.isLogged;
    return cell;
}

- (SFLoginButtonCell *)fabriqueButtonCellWithTitle:(NSString *)title
{
    SFLoginButtonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSFLoginButtonCellIdentifier];
    [cell.button setTitle:title forState:UIControlStateNormal];
    //[cell.button addTarget:self action:@selector(handleLoginLogoutWithCompletion:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SFLoginTextFieldCell class]) bundle:nil]
         forCellReuseIdentifier:kSFLoginTextFieldCellIdentifier];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SFLoginButtonCell class]) bundle:nil]
         forCellReuseIdentifier:kSFLoginButtonCellIdentifier];

    self.clearsSelectionOnViewWillAppear = NO;

    NSInteger numberOfRows = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfRows)]) {
        if (![self.dataSource numberOfRows] < 0) {
            numberOfRows = [self.dataSource numberOfRows];
        }
    }
    else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Please, provide number of rows.", NSStringFromClass([self class])] userInfo:nil];
    }
    
    if (numberOfRows > 0) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(commonLogin:cellAttributesForRowAtIndex:)]) {
            for (int i = 0; i < numberOfRows; i++) {
                
            }
        }
        else {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Please, provide a valid cell attributes of kind CommonLoginCellInfo.", NSStringFromClass([self class])] userInfo:nil];
            
        }
    }
    
    /*
    self.cells = @[[self fabriqueTextCellWithLabel:@"Username"
                                              text:username secureTextEntry:NO
                                      placeHoolder:@"esempio@gmail.com"
                                               tag:SFLoginTextFiledUsername],
                   [self fabriqueTextCellWithLabel:@"Password"
                                              text:password
                                   secureTextEntry:YES
                                      placeHoolder:@"obbligatorio"
                                               tag:SFLoginTextFiledPassowrd],
                   [self fabriqueTextCellWithLabel:@"Fidelity"
                                              text:nil
                                   secureTextEntry:NO
                                      placeHoolder:@"(opzionale)"
                                               tag:SFLoginTextFiledFidelity],
                   [self fabriqueButtonCellWithTitle:nil]];
    //*/
    
    //handle dismissing keyboard
    UITapGestureRecognizer* tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    [self updateButtonState];
}

#pragma mark -
#pragma mark Handle dismissing keyboard

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cells objectAtIndex:indexPath.row];
}

#pragma mark -
#pragma mark - Table view data source

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *nextField = [self textFieldWithTag:textField.tag+1];
    if (nextField == nil) {
        [textField resignFirstResponder];
        
        if ([[self textWithTextField:((SFLoginTextFieldCell *)[self.cells objectAtIndex:0]).textField] length] > 0 &&
            [[self textWithTextField:((SFLoginTextFieldCell *)[self.cells objectAtIndex:1]).textField] length] > 0) {
            /*
            [self handleLoginLogoutWithCompletion:^(BOOL success) {
                //do something
            }];
            //*/
        }
    }
    else {
        [nextField becomeFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma Utility methods

- (NSString *)textWithTextField:(UITextField *)textField
{
    return [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (UITextField *)textFieldWithTag:(NSUInteger)tag
{
    id view = [self.view viewWithTag:tag];
    if ([view isKindOfClass:[UITextField class]]) {
        return view;
    }
    return nil;
}

- (void)textFieldDidChange:(NSNotification *)notificiation
{
    [self updateButtonState];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self updateButtonState];
    return YES;
}

- (void)updateButtonState
{
    UIButton *button = ((SFLoginButtonCell *)[self.cells objectAtIndex:3]).button;
    button.enabled = (([[self textWithTextField:((SFLoginTextFieldCell *)[self.cells objectAtIndex:0]).textField] length] > 0 &&
                      [[self textWithTextField:((SFLoginTextFieldCell *)[self.cells objectAtIndex:1]).textField] length] > 0));
    [button setTitle:(self.isLogged) ? @"Sign Out" : @"Sign In" forState:UIControlStateNormal];
}

/*
- (void)handleLoginLogoutWithCompletion:(LoginCompletionHandler)completion
{
    [self.view endEditing:YES];
    
    if (self.isLogged) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(logout)]) {
            [self.delegate logout];
        }
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginWithCreadentials:)]) {
            NSDictionary *credentials = @{@"username" : ((SFLoginTextFieldCell *)[self.cells objectAtIndex:0]).textField.text,
                                          @"password" : ((SFLoginTextFieldCell *)[self.cells objectAtIndex:1]).textField.text};
            [self.delegate loginWithCreadentials:credentials];
        }
    }
}
//*/
 
- (void)loginFinished
{
    //do something
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.view layoutIfNeeded];
}

@end
