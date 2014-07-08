//
//  TweetCell.m
//  iosTwitter
//
//  Created by Sudip Shah on 6/28/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "TweetCell.h"
#import <UIImageView+AFNetworking.h>
#import "NewTweetViewController.h"
#import "TwitterClient.h"

@interface TweetCell ()

- (IBAction)replyTweet:(id)sender;
- (IBAction)retweet:(id)sender;
- (IBAction)favoriteTweet:(id)sender;


@end

@implementation TweetCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setTweet:(Tweet *)tweet {
    
    _tweet = tweet;
    self.authorName.text = tweet.author.name;
    self.authorId.text = [NSString stringWithFormat:@"@%@",tweet.author.screenName];
    self.tweetText.text = tweet.text;
    [self.authorImage setImageWithURL:tweet.author.profileURL];
    self.tweetTime.text = [tweet timeSinceTweet];
    if (tweet.retweeter) {
        self.retweeterHeightConstraint.constant = 15;
        self.retweeter.text = [NSString stringWithFormat:@"%@ retweeted", tweet.retweeter.name];
    } else {
        self.retweeterHeightConstraint.constant = 0;
        //[self.retweeter removeFromSuperview];
    }
    if (!self.tweet.isFavorited) {
        UIImage *unfavoriteImage = [UIImage imageNamed:@"favorite"];
        [self.favoriteButton setImage:unfavoriteImage forState:UIControlStateNormal];
    } else {
        UIImage *favoriteImage = [UIImage imageNamed:@"favoriteorange"];
        [self.favoriteButton setImage:favoriteImage forState:UIControlStateNormal];
    }
    
    if (!self.tweet.isRetweeted) {
        UIImage *unretweetImage = [UIImage imageNamed:@"retweet"];
        [self.retweetButton setImage:unretweetImage forState:UIControlStateNormal];
    } else {
        UIImage *retweetImage = [UIImage imageNamed:@"retweetorange"];
        [self.retweetButton setImage:retweetImage forState:UIControlStateNormal];
    }

}

- (IBAction)replyTweet:(id)sender {
    
    //NSLog(@"Reply tweet");
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.tweet forKey:@"tweet"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"replyTweet" object:nil userInfo:dictionary];
        
}

- (IBAction)retweet:(id)sender {
    
    if (!self.tweet.isRetweeted) {
        
        
        [[TwitterClient instance] retweetPost:self.tweet.tweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Retweeted!");
            self.tweet.retweetCount += 1;
            //NSLog(@"Retweeted object: %@", responseObject);
            self.tweet.retweetId = responseObject[@"id_str"];
            //NSLog(@"Retweed Id added: %@", self.tweet.retweetId);
            self.tweet.isRetweeted = YES;
            UIImage *retweetImage = [UIImage imageNamed:@"retweetorange"];
            [self.retweetButton setImage:retweetImage forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Retweet failed!");
        }];
        
    } else {
        //NSLog(@"Retweet Id to be removed: %@", self.tweet.retweetId);
        [[TwitterClient instance] destroyTweet:self.tweet.retweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Retweet removed");
            self.tweet.retweetCount -= 1;
            self.tweet.isRetweeted = NO;
            UIImage *unretweetImage = [UIImage imageNamed:@"retweet"];
            [self.retweetButton setImage:unretweetImage forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Retweet removal failed");
        }];
    }
    
}

- (IBAction)favoriteTweet:(id)sender {
    
    if (!self.tweet.isFavorited) {
        
        [[TwitterClient instance] favoriteTweet:self.tweet.tweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Favorited!");
            self.tweet.isFavorited = YES;
            self.tweet.favoritesCount += 1;
            UIImage *favoriteImage = [UIImage imageNamed:@"favoriteorange"];
            [self.favoriteButton setImage:favoriteImage forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Favoriting failed");
        }];
        
    } else {
        
        [[TwitterClient instance] unFavoriteTweet:self.tweet.tweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Unfavorited");
            self.tweet.isFavorited = NO;
            self.tweet.favoritesCount -= 1;
            UIImage *unfavoriteImage = [UIImage imageNamed:@"favorite"];
            [self.favoriteButton setImage:unfavoriteImage forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unfavorite failed");
        }];
    }
    
}


@end
