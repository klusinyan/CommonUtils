
@implementation UIView (AutoLayout)

- (void)layoutAttributeCenterX
{
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0];
    [self.superview addConstraint:c];
}

- (void)layoutAttributeCenterY
{
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.superview
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0];
    [self.superview addConstraint:c];
}

- (void)layoutAttributeCenterX_Y
{
    [self layoutAttributeCenterX];
    [self layoutAttributeCenterY];
}

- (void)layoutAttributeWithSize:(CGSize)size
               attributeCenterX:(BOOL)attributeCenterX
               attributeCenterY:(BOOL)attributeCenterY
{
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1
                                                              constant:size.width];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:size.height];
    
    [self.superview addConstraints:@[width, height]];
    
    if (attributeCenterX) {
        [self layoutAttributeCenterX];
    }
    if (attributeCenterY) {
        [self layoutAttributeCenterY];
    }
}

- (void)resizeWithConstraint:(NSLayoutConstraint *)constraint
                    constant:(CGFloat)constant
                    duration:(NSTimeInterval)duration
                  completion:(void(^)(BOOL finished))completion
{
    [self layoutIfNeeded];
    
    constraint.constant = constant;
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         if (completion) completion(finished);
                     }];
}

@end