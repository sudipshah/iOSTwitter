//
//  TweetCell.h
//  iosTwitter
//
//  Created by Sudip Shah on 6/28/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "NewTweetViewController.h"

@class TweetCell;

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *authorImage;
@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet UILabel *authorId;
@property (weak, nonatomic) IBOutlet UILabel *tweetTime;
@property (weak, nonatomic) IBOutlet UILabel *retweeter;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweeterHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;


@property (strong, nonatomic) Tweet * tweet;

@end
