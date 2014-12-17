//  Created by Karen Lusinyan on 11/09/14.

#import "SFLoginCell.h"

static NSString * const kSFLoginTextFieldCellIdentifier = @"SFLoginTextFieldCellIdentifier";

@interface SFLoginTextFieldCell : SFLoginCell

@property (readwrite, nonatomic, strong) IBOutlet UILabel *label;
@property (readwrite, nonatomic, strong) IBOutlet UITextField *textField;

@end
