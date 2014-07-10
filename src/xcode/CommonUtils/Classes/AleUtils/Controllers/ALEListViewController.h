//  Created by Alessio on 10/12/13.

//  Generic controller for a simple list with one section.
//  The default implementation assumes the datasource to be an array of NSString and display the strings in the tableview using a default cell. If you want to use custom objects and custom cells you have to subclass the list controller and override the relevant methods.
//  If a delegate is set, the list controllers calls it when an element is selected. You can select an element from outside, but in that case the delegate won't be called.
//  You can subclass the list controller or use as is.

#import "ALESecondaryViewControllerDelegate.h"

@interface ALEListViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>

//the list controller calls the delegate on selection of an element
@property (nonatomic, assign) id<ALESecondaryViewControllerDelegate>delegate;

//the list controller's title property is set to this value
@property (nonatomic, copy) NSString *titoloLista;

//the datasource for the list. The list is refreshed when you set this property
@property (nonatomic, copy) NSMutableArray *listArray;

//controls wheter the list controller should display a search bar as a header of the tableview
@property (nonatomic, assign) BOOL showSearchBar;

//only meaningful when showSearchBar is set to YES
@property (nonatomic, strong, readonly) UISearchBar *searchBar;

//controls weather the tableview should be offset so that when the view appears the searchbar remains hidden under the navbar
@property (nonatomic, assign) BOOL searchBarAlwaysVisible;

//the tableview associated with the list
@property (retain, nonatomic) IBOutlet UITableView *tableView;

 //if YES, display the loading interface on load if the list is empty, default is NO
@property (nonatomic, assign) BOOL showLoadingInterfaceIfListEmpty;

//designated initializer
- (id)initWithStyle:(UITableViewStyle)style;

//use this method to select a list element from outside (the delegate won't be called in that case)
- (void)selectListElement:(NSUInteger)elementIndex animated:(BOOL)animated;

//use these methods to display/hide a loading indicator while you load the content for the table
- (void)showLoadingInterface;
- (void)hideLoadingInterface;

@end
