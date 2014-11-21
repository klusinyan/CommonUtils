//  Created by Karen Lusinyan on 11/09/14.

#import "SFLoginCell.h"

static NSString * const kSFLoginButtonCellIdentifier = @"SFLoginButtonCellIndetifier";

@interface SFLoginButtonCell : SFLoginCell

@property (readwrite, nonatomic, strong) IBOutlet UIButton *button;

@end
