//
//  NewTweetViewController.h
//  iosTwitter
//
//  Created by Sudip Shah on 7/1/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "User.h"


@class NewTweetViewController;
@protocol NewTweetViewControllerDelegate <NSObject>

-(void) addItemViewController:(NewTweetViewController *)controller sendBackNewTweet: (Tweet *)newTweet;

@end

@interface NewTweetViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Tweet *tweet;
@property (nonatomic, weak) id <NewTweetViewControllerDelegate> delegate;

@end
