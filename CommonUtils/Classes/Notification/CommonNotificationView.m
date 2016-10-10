//  Created by Karen Lusinyan on 10/10/2016.

#import "CommonNotificationView.h"

@interface CommonNotificationView ()

@property (nonatomic, weak) IBOutlet UIView *container;
@property (nonatomic, weak) IBOutlet UIView *viewHeader;
@property (nonatomic, weak) IBOutlet UIButton *logo;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *message;
@property (nonatomic, weak) IBOutlet UIButton *button;

- (IBAction)buttonAction:(id)sender;

@end

@implementation CommonNotificationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.logo.layer.cornerRadius = 8.0;
}

- (void)setAlertBody:(NSString *)alertBody
{
    self.title.text = alertBody;
    
    _alertBody = alertBody;
}

- (void)setAlertMessage:(NSString *)alertMessage
{
    self.message.text = alertMessage;
    
    _alertMessage = alertMessage;
}

- (IBAction)buttonAction:(id)sender
{
    if (self.alertAction) self.alertAction();
}

#pragma mark - getter/setter

- (void)setImageIcon:(UIImage *)imageIcon
{
    [self.logo setImage:imageIcon forState:UIControlStateNormal];
    
    _imageIcon = imageIcon;
}

@end
