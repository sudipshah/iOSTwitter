//
//  TweetDetailsViewController.m
//  iosTwitter
//
//  Created by Sudip Shah on 6/30/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import <UIImageView+AFNetworking.h>
#import "NewTweetViewController.h"
#import "TwitterClient.h"

@interface TweetDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet UILabel *authorScreenName;
@property (weak, nonatomic) IBOutlet UIImageView *authorImage;
@property (weak, nonatomic) IBOutlet UILabel *tweetDescription;
@property (weak, nonatomic) IBOutlet UILabel *tweetTime;
@property (weak, nonatomic) IBOutlet UILabel *retweetNumber;
@property (weak, nonatomic) IBOutlet UILabel *favoriteNumber;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweeterHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

- (IBAction)replyBack:(id)sender;
- (IBAction)retweet:(id)sender;
- (IBAction)favoriteTweet:(id)sender;

@end

@implementation TweetDetailsViewController

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
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated {
    
    self.authorName.text = self.tweet.author.name;
    self.authorScreenName.text = [NSString stringWithFormat:@"@%@", self.tweet.author.screenName];
    [self.authorImage setImageWithURL:self.tweet.author.profileURL];
    self.tweetDescription.text = self.tweet.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/d/yy, h:mm a"];
    self.tweetTime.text = [formatter stringFromDate:self.tweet.createdAt];
    
    self.retweetNumber.text = [NSString stringWithFormat:@"%d RETWEETS", self.tweet.retweetCount];
    self.favoriteNumber.text = [NSString stringWithFormat:@"%d FAVORITES", self.tweet.favoritesCount];
    if (self.tweet.retweeter) {
        self.retweetLabel.text = [NSString stringWithFormat:@"%@ retweeted", self.tweet.retweeter.name];
        self.retweeterHeightConstraint.constant = 20;
    } else {
        self.retweeterHeightConstraint.constant = 0;
    }
    
    if (self.tweet.isRetweeted) {
        UIImage *retweetImage = [UIImage imageNamed:@"retweetorange"];
        [self.retweetButton setImage:retweetImage forState:UIControlStateNormal];
        
    } else {
        UIImage *unretweetImage = [UIImage imageNamed:@"retweet"];
        [self.retweetButton setImage:unretweetImage forState:UIControlStateNormal];
        
    }
    if (self.tweet.isFavorited) {
        UIImage *favoriteImage = [UIImage imageNamed:@"favoriteorange"];
        [self.favoriteButton setImage:favoriteImage forState:UIControlStateNormal];
        
    } else {
        UIImage *unfavoriteImage = [UIImage imageNamed:@"favorite"];
        [self.favoriteButton setImage:unfavoriteImage forState:UIControlStateNormal];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)replyBack:(id)sender {
    
    NewTweetViewController *ntvc = [[NewTweetViewController alloc]init];
    ntvc.tweet = self.tweet;
    [self.navigationController pushViewController:ntvc animated:YES];
    
}

- (IBAction)retweet:(id)sender {
    
    
    if (!self.tweet.isRetweeted) {
        
        
        [[TwitterClient instance] retweetPost:self.tweet.tweetId success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Retweeted!");
            self.tweet.retweetCount += 1;
            self.retweetNumber.text = [NSString stringWithFormat:@"%d RETWEETS", self.tweet.retweetCount];
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
            self.retweetNumber.text = [NSString stringWithFormat:@"%d RETWEETS", self.tweet.retweetCount];
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
            self.favoriteNumber.text = [NSString stringWithFormat:@"%d FAVORITES", self.tweet.favoritesCount];
            
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
            self.favoriteNumber.text = [NSString stringWithFormat:@"%d FAVORITES", self.tweet.favoritesCount];
            
            UIImage *unfavoriteImage = [UIImage imageNamed:@"favorite"];
            [self.favoriteButton setImage:unfavoriteImage forState:UIControlStateNormal];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Unfavorite failed");
        }];
    }
    
}

@end
