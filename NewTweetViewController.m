//
//  NewTweetViewController.m
//  iosTwitter
//
//  Created by Sudip Shah on 7/1/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "NewTweetViewController.h"
#import <UIImageView+AFNetworking.h>
#import "TwitterClient.h"


@interface NewTweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *authorImage;
@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet UILabel *authorScreenName;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;

@property (strong, nonatomic) UIBarButtonItem *tweetButton;
@property (strong, nonatomic) UIBarButtonItem *characterCount;

- (void) onTweetButton;
- (void) onCancelButton;

@end

@implementation NewTweetViewController

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

    
}

-(void)viewWillAppear:(BOOL)animated {
    
    User *currentUser = [User currentUser];
    self.authorName.text = currentUser.name;
    self.authorScreenName.text = currentUser.screenName;
    [self.authorImage setImageWithURL:currentUser.profileURL];
    
    self.tweetText.delegate = self;
    
    self.navigationItem.title = @"New Tweet";
    
    self.tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButton)];
    self.tweetButton.enabled = NO;
    
    self.characterCount = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[self.tweetButton, self.characterCount];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    
    if (self.tweet) {
        self.tweetText.text = [NSString stringWithFormat:@"@%@", self.tweet.author.screenName];
    } else {
        self.self.characterCount.tintColor = [UIColor redColor];
    }
    
    [self.tweetText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textViewDidChange:(UITextView *)textView {
    
    int count = 140 - (int) textView.text.length;
    if (count > 0 && count < 140) {
        
        self.characterCount.title = [NSString stringWithFormat:@"%d", count];
        self.tweetButton.enabled = YES;
        self.characterCount.tintColor = [UIColor blueColor];

    } else {
        
        self.tweetButton.enabled = NO;
        self.characterCount.title = [NSString stringWithFormat:@"%d", count > 0 ? count: -count];
        self.characterCount.tintColor = [UIColor redColor];
    }
    
}



- (void) onTweetButton {
    
    User * currentUser = [User currentUser];
    NSLog(@"Tweet!");
    
    if (self.tweet) {
        
        [[TwitterClient instance] postReplyTweet:self.tweetText.text replyTo:[NSString stringWithFormat:@"%d", self.tweet.author.userId] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            self.tweet.author = currentUser;
            self.tweet.text = self.tweetText.text;
            self.tweet.createdAt = [NSDate date];
            //[self.delegate addItemViewController:self sendBackNewTweet:self.tweet];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error");
        }];
        
    } else {
        
        [[TwitterClient instance] postNewTweet:self.tweetText.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"New tweet posted");
            self.tweet = [[Tweet alloc]init];
            self.tweet.author = currentUser;
            self.tweet.text = self.tweetText.text;
            self.tweet.createdAt = [NSDate date];
            [self.delegate addItemViewController:self sendBackNewTweet:self.tweet];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error");
        }];
        
    }
    
    
}

- (void) onCancelButton {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
