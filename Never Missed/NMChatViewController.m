
#import "NMChatViewController.h"
#import "NMChatDetailViewController.h"

@interface NMChatViewController()
{
	NSTimer *timer;
	BOOL isLoading;
    
	NSMutableArray *users;
	NSMutableArray *messages;
	NSMutableDictionary *avatars;
    
	UIImageView *outgoingBubbleImageView;
	UIImageView *incomingBubbleImageView;
    
    NSString *_name;
}
@end

@implementation NMChatViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
    self.tabBarController.tabBar.hidden=YES;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _name = [defaults objectForKey:@"name"];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = [self.connectionUser objectForKey:@"name"];
    [label sizeToFit];
    
    UIBarButtonItem *detailButton = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(detailButtonTapped)];
    self.navigationItem.rightBarButtonItem = detailButton;
    
	users = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];
    
	self.sender = [PFUser currentUser].objectId;
    
	outgoingBubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	incomingBubbleImageView = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleBlueColor]];
    
	isLoading = NO;
	[self loadMessages];
    self.inputToolbar.contentView.leftBarButtonItem = nil;
	timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

-(void)detailButtonTapped {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMChatDetailViewController *vc = (NMChatDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chatDetail"];
    vc.connectionUser = self.connectionUser;
    vc.connection = self.connection;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden=NO;
	[timer invalidate];
}


- (void)loadMessages
{
	if (isLoading == NO)
	{

		isLoading = YES;
		JSQMessage *message_last = [messages lastObject];
		PFQuery *query = [PFQuery queryWithClassName:@"Message"];
		[query whereKey:@"conversationId" equalTo:self.connection];
		if (message_last != nil) [query whereKey:@"createdAt" greaterThan:message_last.date];
        [query setLimit:1000];
        //[query setSkip:messages.count];
		[query includeKey:@"user"];
        //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
		[query orderByAscending:@"createdAt"];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 NSLog(@"Loaded Messages Successfully");
                 for (PFObject *object in objects)
                 {
                     PFUser *user = object[@"user"];
                     [users addObject:user];
                     
                     JSQMessage *message = [[JSQMessage alloc] initWithText:object[@"text"] sender:user.objectId date:object.createdAt];
                     [messages addObject:message];
                 }
                 NSLog(@"MESSAGES SIZE: %lu", (unsigned long)messages.count);
                 if ([objects count] != 0) [self finishReceivingMessage];
             }
             else {
                 // [ProgressHUD showError:@"Network error."];
                 NSLog(@"Error Loading Messages");
             }
             isLoading = NO;
         }];
	}
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
{
	PFObject *object = [PFObject objectWithClassName:@"Message"];
	object[@"conversationId"] = self.connection;
	object[@"user"] = [PFUser currentUser];
	object[@"text"] = text;
	[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             /*PFPush *push = [[PFPush alloc] init];
             NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"message", @"type",
                                   text, @"messageBody",
                                   _connection.objectId, @"connection",
                                   @"New Message", @"alert",
                                   _name, @"name",
                                   @"Increment", @"badge",
                                   nil];
             [push setChannel:[NSString stringWithFormat:@"user_%@", [NSString stringWithFormat:@"%@", _connectionUser.objectId]]];
             [push setData:data];
             [push sendPushInBackground];*/
             [self loadMessages];
         }
         else {
             NSLog(@"Error Sending Message");
         }
     }];
    _connection[@"lastMessage"] = text;
    [_connection saveInBackground];
	[self finishSendingMessage];
}


- (void)didPressAccessoryButton:(UIButton *)sender
{
	NSLog(@"didPressAccessoryButton");
}

#pragma mark - JSQMessages CollectionView DataSource


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return [messages objectAtIndex:indexPath.item];
}


- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([[message sender] isEqualToString:self.sender])
	{
		return [[UIImageView alloc] initWithImage:outgoingBubbleImageView.image highlightedImage:outgoingBubbleImageView.highlightedImage];
	}
	else return [[UIImageView alloc] initWithImage:incomingBubbleImageView.image highlightedImage:incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
	PFUser *user = [users objectAtIndex:indexPath.item];
    
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_avatar"]];
	if (avatars[user.objectId] == nil)
	{
		PFFile *filePicture = user[@"profilePicture"];
		[filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 avatars[user.objectId] = [UIImage imageWithData:imageData];
                 [imageView setImage:avatars[user.objectId]];
             }
         }];
	}
	else [imageView setImage:avatars[user.objectId]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.layer.cornerRadius = imageView.frame.size.width/2;
	imageView.layer.masksToBounds = YES;
    
	return imageView;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = [messages objectAtIndex:indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	/*JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([message.sender isEqualToString:self.sender])
	{
		return nil;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString:message.sender])
		{
			return nil;
		}
	}
    
	PFUser *user = [users objectAtIndex:indexPath.item];
	return [[NSAttributedString alloc] initWithString:user[@"name"]];*/
    return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([message.sender isEqualToString:self.sender])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	
	cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:cell.textView.textColor,
										 NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid)};
	
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([[message sender] isEqualToString:self.sender])
	{
		return 0.0f;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString:[message sender]])
		{
			return 0.0f;
		}
	}
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
	return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender

{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

@end
