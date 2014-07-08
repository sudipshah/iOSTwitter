//
//  Tweet.h
//  iosTwitter
//
//  Created by Sudip Shah on 6/26/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (strong, nonatomic) User * author;
@property (strong, nonatomic) User *retweeter;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSDate *createdAt;
@property int retweetCount;
@property int favoritesCount;
@property BOOL isFavorited;
@property (strong, nonatomic) NSString *tweetId;
@property (strong, nonatomic) NSString *retweetId;


@property BOOL isRetweeted;

-(Tweet *)initWithDictionary: (NSDictionary *) data;

- (NSString *) timeSinceTweet;

-(void)retweet;

-(void)unRetweet;

-(void)favoriteTweet;

-(void)unFavoriteTweet;

@end
