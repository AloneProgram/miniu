#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface LZJTestChatListViewController : BaseViewController

- (void)refreshDataSource;

- (void)networkChanged:(EMConnectionState)connectionState;

@end