//  Created by Karen Lusinyan on 11/04/14.

#import "CustomCell.h"

@interface CustomCell ()

@end

@implementation CustomCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        self.imageViewCanvas = [[CSAnimationView alloc] init];
        self.imageViewCanvas.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageViewCanvas.layer.cornerRadius = 20;
        self.imageViewCanvas.contentMode = UIViewContentModeCenter;
        self.imageViewCanvas.backgroundColor = [UIColor greenColor];
        
        //personilze canvas
        self.imageViewCanvas.duration = 0.5;
        self.imageViewCanvas.delay    = 0;
        self.imageViewCanvas.type     = CSAnimationTypeMorph;
        
        [self.contentView addSubview:self.imageViewCanvas];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.layer.cornerRadius = 20;
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.imageViewCanvas addSubview:self.imageView];
        
        self.lblNome = [[UILabel alloc] init];
        //self.label_1.backgroundColor = [UIColor whiteColor];
        self.lblNome.translatesAutoresizingMaskIntoConstraints = NO;
        self.lblNome.textAlignment = NSTextAlignmentLeft;
        self.lblNome.font = [UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:self.lblNome];
        
        self.lblDescr = [[UILabel alloc] init];
        //self.label_2.backgroundColor = [UIColor whiteColor];
        self.lblDescr.translatesAutoresizingMaskIntoConstraints = NO;
        self.lblDescr.textAlignment = NSTextAlignmentLeft;
        self.lblDescr.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.lblDescr];
        
        self.lblPeriodo = [[UILabel alloc] init];
        //self.label_3.backgroundColor = [UIColor whiteColor];
        self.lblPeriodo.translatesAutoresizingMaskIntoConstraints = NO;
        self.lblPeriodo.textAlignment = NSTextAlignmentLeft;
        self.lblPeriodo.font = [UIFont systemFontOfSize:14];
        self.lblPeriodo.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.lblPeriodo];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1
                                                          constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewCanvas
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:114]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewCanvas
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1
                                                                      constant:114]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewCanvas
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:8]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewCanvas
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:8]];

        [self.imageViewCanvas addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(_imageView)]];
        
        [self.imageViewCanvas addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(_imageView)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_imageViewCanvas(==114)]-8-[_lblNome]-8-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_imageViewCanvas, _lblNome)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_imageViewCanvas(==114)]-8-[_lblDescr]-8-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_imageViewCanvas, _lblDescr)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[_imageViewCanvas(==114)]-8-[_lblPeriodo]-8-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_imageViewCanvas, _lblPeriodo)]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=8-[_lblNome(==20)]-8-[_lblDescr(==20)]-8-[_lblPeriodo(==20)]->=8-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(_lblNome, _lblDescr, _lblPeriodo)]];
        
        
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}


//only nib
- (void)awakeFromNib
{
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
