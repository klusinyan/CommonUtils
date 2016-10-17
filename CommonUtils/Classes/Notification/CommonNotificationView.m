//  Created by Karen Lusinyan on 10/10/2016.

#import "CommonNotificationView.h"

@interface CommonNotificationView ()
<
UIGestureRecognizerDelegate
>

@property (nonatomic, weak) IBOutlet UIView *container;
@property (nonatomic, weak) IBOutlet UIView *viewHeader;
@property (nonatomic, weak) IBOutlet UIButton *logo;
@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UIView *viewMessage;
@property (nonatomic, weak) IBOutlet UILabel *message;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UIView *viewGesture;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *viewGestureHeight;
@property (nonatomic, weak) IBOutlet UIPanGestureRecognizer *panGesture;
@property (nonatomic, getter=isDragging) BOOL dragging;
@property (nonatomic) BOOL extended;

- (IBAction)buttonAction:(UIButton *)sender;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender;

@end

@implementation CommonNotificationView

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.logo.layer.cornerRadius = 8.0;
}

#pragma mark - getter/setter

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

- (void)setSetExtandable:(BOOL)setExtandable
{
    if (setExtandable) {
        self.viewGesture.layer.cornerRadius = 2;
        self.viewGestureHeight.constant = 5;
    }
    
    _setExtandable = setExtandable;
}

#pragma mark - bottons

- (IBAction)buttonAction:(UIButton *)sender
{
    if (!self.isDragging) {
        if (self.alertAction) self.alertAction();
    }
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (!self.isDragging) {
        CGPoint velocity = [gesture velocityInView:self];
        if(velocity.y > 0) {
            self.message.adjustsFontSizeToFitWidth = YES;
            if (self.presentFromTop) {
                if (!self.extended && self.isExtandable) {
                    self.extended = YES;
                    if (self.dragDown) self.dragDown();
                }
            }
            else {
                self.message.adjustsFontSizeToFitWidth = NO;
                if (self.extended && self.isExtandable) {
                    self.extended = NO;
                    if (self.dragUp) self.dragUp();
                }
                else {
                    if (self.dragToDimiss) self.dragToDimiss();
                }
            }
        }
        else {
            if (self.presentFromTop) {
                self.message.adjustsFontSizeToFitWidth = NO;
                if (self.extended && self.isExtandable) {
                    self.extended = NO;
                    if (self.dragUp) self.dragUp();
                }
                else {
                    if (self.dragToDimiss) self.dragToDimiss();
                }
            }
            else {
                self.message.adjustsFontSizeToFitWidth = YES;
                if (!self.extended && self.isExtandable) {
                    self.extended = YES;
                    if (self.dragDown) self.dragDown();
                }
            }
        }
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.dragging = YES;

    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.dragging = NO;
    }
}

#pragma mark - getter/setter

- (void)setImageIcon:(UIImage *)imageIcon
{
    [self.logo setImage:imageIcon forState:UIControlStateNormal];
    
    _imageIcon = imageIcon;
}

@end
