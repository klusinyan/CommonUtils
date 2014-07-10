//  Created by Karen Lusinyan on 11/29/12.
//  Copyright (c) 2012 Home. All rights reserved.

#pragma mark -
#pragma mark version 2.1.0 (added support to !arc projects)

#import "SelectedElementDelegate.h"

@protocol SelectedListControllerDelegate;

typedef NS_ENUM(NSInteger, SelectionType) {
    SelectionTypeTypeUnknown        = 0,
    SelectionTypeSingleElement      = 1 << 0,
    SelectionTypeIndexPath          = 1 << 1,
    SelectionTypeFilteredDataSource = 1 << 2,
};

typedef NS_OPTIONS(NSUInteger, SelectionTypeMask) {
    SelectionTypeMaskIndexPathFilteredDataSource = (SelectionTypeIndexPath | SelectionTypeFilteredDataSource),
    SelectionTypeMaskSingleElementFilteredDataSource = (SelectionTypeSingleElement | SelectionTypeFilteredDataSource),
    SelectionTypeMaskAll = (SelectionTypeSingleElement | SelectionTypeIndexPath | SelectionTypeFilteredDataSource),
};

@interface SelectedListController : UIViewController

@property (readwrite, nonatomic, assign) id<SelectedListControllerDelegate> delegate;

@property (readwrite, nonatomic, retain) NSArray *dataSource;

@property (readwrite, nonatomic, retain) UIColor *color;

@property (readwrite, nonatomic, retain) NSString *headerTitle;

@property (readwrite, nonatomic, assign) SelectionType selectionType;   //default type SelectionTypeSingleElement

@property (readwrite, nonatomic, assign) BOOL searchEnabled;            //default NO

@property (readwrite, nonatomic, assign) BOOL backWhenSelected;         //default YES

@property (readwrite, nonatomic, assign) NSInteger tag;                 //default -1

@property (readwrite, nonatomic, copy) NSString* keyPath;               //default nil

- (id)initWithTableViewStyle:(UITableViewStyle)tableViewStyle
                   rowHeight:(CGFloat)rowHeight
                  dataSource:(NSArray *)dataSource
      andWithSelectedElement:(id)selectedElement;

- (void)reloadDataSource;

@end

//extends generic SelectedElementDelegate
@protocol SelectedListControllerDelegate <SelectedElementDelegate>

@optional
- (void) filteredDataSource:(NSArray *)dataSource withTag:(NSInteger)tag;

@end
