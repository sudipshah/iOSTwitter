//
//  Tweet.m
//  iosTwitter
//
//  Created by Sudip Shah on 6/26/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "Tweet.h"
#import "USer.h"
#import "TwitterClient.h"

@interface Tweet ()

@property NSString * timeFromTweet;
@property NSDictionary *rawTweet;


@end

@implementation Tweet

-(Tweet *)initWithDictionary: (NSDictionary *) data {
    
    //NSLog(@"Data: %@", data);
    Tweet *tweet = [[Tweet alloc]init];
    tweet.tweetId = data[@"id_str"];
    tweet.rawTweet = data;
    
    NSDictionary *retweet = data[@"retweeted_status"];
    
    if(retweet) {
        tweet.retweeter = [[User alloc] initWithDictionary:data[@"user"]];
        tweet.author = [[User alloc] initWithDictionary:retweet[@"user"]];
        tweet.text = retweet[@"text"];
        tweet.createdAt = [self dateString:retweet[@"created_at"]];
    } else {
        tweet.text = data[@"text"];
        tweet.author = [[User alloc] initWithDictionary:data[@"user"]];
        tweet.createdAt = [self dateString:data[@"created_at"]];
    }
    
    tweet.retweetCount = [data[@"retweet_count"] integerValue];
    tweet.isRetweeted = [data[@"retweeted"] boolValue];
    
    tweet.favoritesCount = [data[@"favorite_count"] integerValue];
    tweet.isFavorited = [data[@"favorited"] boolValue];
    
    if (tweet.rawTweet[@"current_user_retweet"]) {
        tweet.retweetId = data[@"current_user_retweet"][@"id_str"];
        //NSLog(@"Retweet ID in Tweet.m: %@", tweet.retweetId);
    }
    
    return tweet;
}


- (NSDate *)dateString:(NSString *)string
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
	return [formatter dateFromString:string];
}


- (NSString *) timeSinceTweet {
    
    NSTimeInterval timeInterval = [self.createdAt timeIntervalSinceNow];
    int seconds = (int)(timeInterval * -1);
    
    if (!self.timeFromTweet) {
        if (seconds < 60) {
            self.timeFromTweet = @"now";
        } else if (seconds < 3600) {
            self.timeFromTweet = [NSString stringWithFormat:@"%dm", (seconds/60)];
        } else if (seconds < 86400) {
            self.timeFromTweet = [NSString stringWithFormat:@"%dh", (seconds / 3600)];
        } else if (seconds < 31536000) {
            self.timeFromTweet = [NSString stringWithFormat:@"%dd", (seconds / 86400)];
        } else {
            self.timeFromTweet = [NSString stringWithFormat:@"%dy", (seconds / 31536000)];
        }
    }

    return self.timeFromTweet;    
    
}


-(void)retweet {
    
    [[TwitterClient instance] retweetPost:self.tweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Retweeted!");
        self.retweetCount += 1;
        self.retweetId = responseObject[@"id_str"];
        self.isRetweeted = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Retweet failed!");
    }];
    
}

-(void)unRetweet {
    
    [[TwitterClient instance] destroyTweet:self.retweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Retweet removed");
        self.retweetCount -= 1;
        self.isRetweeted = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Retweet removal failed");
    }];
}

-(void)favoriteTweet {
    
    [[TwitterClient instance] favoriteTweet:self.tweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Favorited!");
        self.isFavorited = YES;
        self.favoritesCount += 1;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Favoriting failed");
    }];
}

-(void)unFavoriteTweet {
    
    [[TwitterClient instance] unFavoriteTweet:self.tweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Unfavorited");
        self.isFavorited = NO;
        self.favoritesCount -= 1;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unfavorite failed");
    }];
    
    
}


@end
