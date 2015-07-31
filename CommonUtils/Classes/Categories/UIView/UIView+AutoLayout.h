
@interface UIView (AutoLayout)

- (void)layoutAttributeCenterX;

- (void)layoutAttributeCenterY;

- (void)layoutAttributeWithSize:(CGSize)size
               attributeCenterX:(BOOL)attributeCenterX
               attributeCenterY:(BOOL)attributeCenterY;

- (void)layoutAttributeCenterX_Y;

- (void)resizeWithConstraint:(NSLayoutConstraint *)constraint
                    constant:(CGFloat)constant
                    duration:(NSTimeInterval)duration
                  completion:(void(^)(BOOL finished))completion;

@end
