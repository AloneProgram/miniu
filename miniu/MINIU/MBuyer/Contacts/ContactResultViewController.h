//
//  ContactResultViewController.h
//  miniu
//
//  Created by SimMan on 5/7/15.
//  Copyright (c) 2015 SimMan. All rights reserved.
//

#import "BaseTableViewController.h"
@class UserEntity;

@protocol ContactResultViewControllerDelegate <NSObject>
- (void) didSelectedUser:(UserEntity *)user;
@end

@interface ContactResultViewController : BaseTableViewController <UISearchResultsUpdating>

@property (nonatomic, assign) id<ContactResultViewControllerDelegate> delegate;

@end
