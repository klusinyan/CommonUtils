//  Created by Karen Lusinyan on 6/21/12.
//  Copyright (c) 2012 Home. All rights reserved.

#import "SelectedListController.h"

#define kVerbose YES

@interface SelectedListController ()  <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate>

@property (readwrite, nonatomic, retain) UISearchBar *searchBar;
@property (readwrite, nonatomic, retain) UITableView *tableView;
@property (readwrite, nonatomic, retain) NSArray *dataSourceCopy;
@property (readwrite, nonatomic, retain) id selectedElement;

@end

@implementation SelectedListController

- (void)dealloc
{
    self.delegate = nil;
#if !__has_feature(objc_arc)
    [_searchBar release];
    [_tableView release];
    [_dataSource release];
    [_dataSourceCopy release];
    [_selectedElement release];
    [_color release];
    [_headerTitle release];
    [_keyPath release];
    [super dealloc];
#endif
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithTableViewStyle:(UITableViewStyle)tableViewStyle
                   rowHeight:(CGFloat)rowHeight
                  dataSource:(NSArray *)dataSource
      andWithSelectedElement:(id)selectedElement
{    
    if (self = [super init]) {

        //set defaults
        self.selectionType = SelectionTypeSingleElement;
        self.searchEnabled = NO;
        self.backWhenSelected = YES;
        self.tag = -1;
        self.keyPath = nil;
        
        self.dataSource = dataSource;
        self.dataSourceCopy = [NSArray arrayWithArray:self.dataSource];
        self.selectedElement = selectedElement;
        
#if !__has_feature(objc_arc)
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:tableViewStyle] autorelease];
#else
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:tableViewStyle];
#endif
        self.tableView.autoresizesSubviews = YES;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = rowHeight;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.tableView];
    }
    return self;
}

- (void)reloadDataSource
{
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void) showSearch
{
#if !__has_feature(objc_arc)
    self.searchBar = [[[UISearchBar alloc] init] autorelease];
#else
    self.searchBar = [[UISearchBar alloc] init];
#endif
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.delegate = self;
    if ([self.searchBar respondsToSelector:@selector(searchBarStyle)]) {
        [self.searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    }
    [self.view addSubview:self.searchBar];
}

- (void)loadView
{
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.autoresizesSubviews = YES;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = contentView;

#if !__has_feature(objc_arc)
    [contentView release];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.selectedElement;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView = nil;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.color != nil) {
        self.navigationController.navigationBar.tintColor = self.color;
    }
    if (self.searchEnabled) {
        [self showSearch];

        CGRect searchRect = self.view.bounds;
        searchRect.origin.y = 0;
        searchRect.size.height = 44;
        self.searchBar.frame = searchRect;
        
        CGRect tableRect = self.view.bounds;
        tableRect.origin.y = CGRectGetMaxY(self.searchBar.frame);
        tableRect.size.height -= CGRectGetMaxY(self.searchBar.frame);
        self.tableView.frame = tableRect;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];        
    }
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Table view delegate and data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
    
    // Return the title of section.
    NSString *title = nil;
    if ([self.headerTitle length] > 0) {
        title = self.headerTitle;
    }
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
#if !__has_feature(objc_arc)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
#else
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
#endif
        if (self.color != nil) {
            //Do nothing
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([[self.dataSource objectAtIndex:indexPath.row] isEqual:self.selectedElement]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

    if (self.keyPath == nil) {
        cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    }
    else {
        id object = [self.dataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = [object valueForKeyPath:self.keyPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
    if ([self.delegate respondsToSelector:@selector(filteredDataSource:withTag:)]) {
        [self.delegate filteredDataSource:self.dataSource withTag:self.tag];
    }

    if (self.selectionType & SelectionTypeSingleElement) {
        if ([self.delegate respondsToSelector:@selector(selectedElement:)]) {
            [self.delegate selectedElement:[self.dataSource objectAtIndex:indexPath.row]];
        }
        if ([self.delegate respondsToSelector:@selector(selectedElement:withTag:)]) {
            [self.delegate selectedElement:[self.dataSource objectAtIndex:indexPath.row] withTag:self.tag];
        }
    }
    else if (self.selectionType & SelectionTypeIndexPath) {
        if ([self.delegate respondsToSelector:@selector(selectedElement:)]) {
            [self.delegate selectedElement:indexPath];
        }
        if ([self.delegate respondsToSelector:@selector(selectedElement:withTag:)]) {
            [self.delegate selectedElement:indexPath withTag:self.tag];
        }
    }
    
    if (self.backWhenSelected) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark UISearchBarDelegate methods

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)startSearchWithText:(NSString *)searchText
{
    if ([searchText length] == 0) {
        self.dataSource = [NSArray arrayWithArray:self.dataSourceCopy];
    }
    else {
        NSMutableArray *filteredDataSource = [NSMutableArray array];
        for (id element in self.dataSourceCopy) {
            NSString *keyPath = element;
            if (self.keyPath != nil) {
                keyPath = [element valueForKeyPath:self.keyPath];
            }
			NSRange elementRange = [keyPath rangeOfString:searchText options:NSCaseInsensitiveSearch | NSLiteralSearch];
            if (elementRange.location != NSNotFound) {
                [filteredDataSource addObject:element];
            }
        }
        
        self.dataSource = [NSArray arrayWithArray:filteredDataSource];
    }

    if ([self.delegate respondsToSelector:@selector(filteredDataSource:withTag:)]) {
        [self.delegate filteredDataSource:self.dataSource withTag:self.tag];
    }
    
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(startSearchWithText:) withObject:searchText afterDelay:0.5];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [self.tableView reloadData];
    [theSearchBar endEditing:YES];
}

@end
