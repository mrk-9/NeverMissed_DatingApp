#import <UIKit/UIKit.h>
#import "JSQMessages.h"
#import <Parse/Parse.h>



@interface NMChatViewController : JSQMessagesViewController


@property (nonatomic, strong) PFObject * connection;
@property (nonatomic, strong) PFUser * connectionUser;

@end
