//
//  TweetsViewController.h
//  iosTwitter
//
//  Created by Sudip Shah on 6/25/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewTweetViewController.h"
#import "TweetCell.h"

@interface TweetsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NewTweetViewControllerDelegate>

@end
