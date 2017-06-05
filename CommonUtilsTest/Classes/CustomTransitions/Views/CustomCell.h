//  Created by Karen Lusinyan on 16/04/14.

@class CommonAnimationView;

@interface CustomCell : UICollectionViewCell

@property (nonatomic, strong) CommonAnimationView *imageViewCanvas;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *lblNome;
@property (nonatomic, strong) UILabel *lblDescr;
@property (nonatomic, strong) UILabel *lblPeriodo;

@end
