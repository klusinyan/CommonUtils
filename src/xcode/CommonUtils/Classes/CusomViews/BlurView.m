// Created by Cesar Pinto Castillo on 7/1/13.
// Modified by Karen Lusinyan 16/06/14.

#import "BlurView.h"

@interface BlurView ()

@property (readwrite, nonatomic, strong) UIToolbar *toolbar;

@end

@implementation BlurView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // If we don't clip to bounds the toolbar draws a thin shadow on top
    [self setClipsToBounds:YES];
    self.clipsToBounds = YES;
    if (!self.toolbar) {
        self.toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:self.toolbar atIndex:0];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                     options:0
                                                                     metrics:0
                                                                       views:NSDictionaryOfVariableBindings(_toolbar)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_toolbar]|"
                                                                     options:0
                                                                     metrics:0
                                                                       views:NSDictionaryOfVariableBindings(_toolbar)]];
    }
}

#pragma mark -
#pragma mark getter/setter

- (void)setBlurTintColor:(UIColor *)blurTintColor
{
    [self.toolbar setBarTintColor:blurTintColor];
}

@end
