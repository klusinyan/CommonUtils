//  Created by Karen Lusinyan on 9/20/12.
//  Copyright (c) 2012 Softec s.p.a. All rights reserved.

@protocol SelectedElementDelegate <NSObject>

@optional
//generic
- (void) selectedElement:(id)element;
//with tag for callback
- (void) selectedElement:(id)element withTag:(NSInteger)tag;
//- (void) selectedElements:(id)elements,...NS_REQUIRES_NIL_TERMINATION;

@end
