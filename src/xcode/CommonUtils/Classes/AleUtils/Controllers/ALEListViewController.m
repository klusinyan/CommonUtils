//
//  CREListViewController.m
//  
//
//  Created by Alessio on 10/12/13.
//
//

#import "ALEListViewController.h"

@interface ALEListViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, strong, readwrite) UISearchBar *searchBar;

- (void)addSearchBarToTableView;
- (void)removeSearchBarFromTableView;
@end

@implementation ALEListViewController

- (id)init
{
    self = [self initWithNibName:nil bundle:nil];
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.tableViewStyle = style;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.showLoadingInterfaceIfListEmpty = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(0, 0, 30, 30);
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.hidden = YES;
    }
    return _activityIndicator;
}

- (void)loadView
{
    UIView *view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.view = view;
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:self.tableViewStyle];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_tableView)]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_tableView)]];
    
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.activityIndicator];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1
                                   constant:0]];
    
    [self.view addConstraint:
     [NSLayoutConstraint constraintWithItem:self.activityIndicator
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:self.view
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1
                                   constant:0]];
    
    
}

#pragma mark - support

- (void)addSearchBarToTableView
{
    self.tableView.tableHeaderView = self.searchBar;
}

- (void)removeSearchBarFromTableView
{
    self.tableView.tableHeaderView = nil;
}

#pragma mark - getter/setter

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]init];
        [_searchBar sizeToFit];
    }
    return _searchBar;
}

- (void)setShowSearchBar:(BOOL)showSearchBar
{
    _showSearchBar = showSearchBar;
    
    _showSearchBar ? ([self addSearchBarToTableView]) : ([self removeSearchBarFromTableView]);
}

- (void)setListArray:(NSMutableArray *)listArray
{
    _listArray = listArray ;
    
    [self hideLoadingInterface];
    
    [self refreshUI];
}

- (void)setTitoloLista:(NSString *)titoloLista
{
    _titoloLista = [titoloLista copy];
    
    [self refreshUI];
}

#pragma mark - interface

- (void)refreshUI
{
    self.title = self.titoloLista;

    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    self.activityIndicator.center = self.view.center;
}

#pragma mark - view lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[self refreshUI];
    
    if (!self.listArray && self.showLoadingInterfaceIfListEmpty) {
        [self showLoadingInterface];
    }
    
    if (self.showSearchBar) {
        [self addSearchBarToTableView];
        if (!self.searchBarAlwaysVisible) {
            [self.tableView setContentOffset: CGPointMake(0, self.searchBar.frame.size.height)];
        }
    }
    else {
        [self removeSearchBarFromTableView];
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
        
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

#pragma mark - tableview delegate & datasource

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listArray count];
}

//override to show custom content
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.listArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectObject:inSecondaryViewController:)]) {
        [self.delegate didSelectObject:self.listArray[indexPath.row] inSecondaryViewController:self];
    }
}

#pragma mark - public

-(void)selectListElement:(NSUInteger)elementIndex animated:(BOOL)animated
{
    NSIndexPath *iPath = [NSIndexPath indexPathForRow:elementIndex inSection:0];
    [self.tableView selectRowAtIndexPath:iPath
                                animated:animated scrollPosition:UITableViewScrollPositionNone];
    [self.tableView scrollToRowAtIndexPath:iPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

-(void)showLoadingInterface
{
    self.tableView.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

-(void)hideLoadingInterface
{
    self.tableView.hidden = NO;
    [self.activityIndicator stopAnimating];
}

@end
