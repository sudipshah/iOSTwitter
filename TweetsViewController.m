//
//  TweetsViewController.m
//  iosTwitter
//
//  Created by Sudip Shah on 6/25/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "TweetsViewController.h"
#import "LoginViewController.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "User.h"
#import "TweetCell.h"
#import "TweetDetailsViewController.h"

@interface TweetsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * homeTimeline;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) Tweet * currentTweet;

- (void) loadHomeTimeLine;
-(void) signOut;
-(void) newTweet;

-(void)replyWithTweet: (NSNotification *) notification;


@end

@implementation TweetsViewController

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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.navigationItem.title = @"Home";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(newTweet)];
    
    UITableViewController *tvc = [[UITableViewController alloc]init];
    tvc.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(loadHomeTimeLine) forControlEvents:UIControlEventValueChanged];
    tvc.refreshControl = self.refreshControl;
    
    [self loadHomeTimeLine];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyWithTweet:) name:@"replyTweet" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadHomeTimeLine {
    
    TwitterClient *twitterClient = [TwitterClient instance];
    self.homeTimeline = [[NSMutableArray alloc]init];
    
    [twitterClient homeTimelineWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray * tweets = responseObject;
        //NSLog(@"response: %@", responseObject);
        for (NSDictionary *dict in tweets) {
            [self.homeTimeline addObject:[[Tweet alloc] initWithDictionary:dict]];
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        //NSLog(@"Loaded data");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response error");
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.refreshControl endRefreshing];
        
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetCell * tweetCell = [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
   
    tweetCell.tweet= self.homeTimeline[indexPath.row];
    self.currentTweet = tweetCell.tweet;
    
    //[tweetCell.replyButton addTarget:self action:@selector(replyTweet) forControlEvents:UIControlEventTouchUpInside];
    //[tweetCell.retweetButton addTarget:self action:@selector(reTweet) forControlEvents:UIControlEventTouchUpInside];
    //[tweetCell.favoriteButton addTarget:self action:@selector(favoriteTweet) forControlEvents:UIControlEventTouchUpInside];
    
    return tweetCell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.homeTimeline count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Tweet * tweet = self.homeTimeline[indexPath.row];
    float retweeterheight = 0;
    if (tweet.retweeter) {
        retweeterheight = 15.0f;
    }
    
    CGRect textRect = [tweet.text boundingRectWithSize:CGSizeMake(225, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
    
    return retweeterheight + 30 + textRect.size.height + 40;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TweetDetailsViewController *tdvc = [[TweetDetailsViewController alloc]initWithNibName:@"TweetDetailsViewController" bundle:nil];
    
    tdvc.tweet = self.homeTimeline[indexPath.row];
    
    [self.navigationController pushViewController:tdvc animated:YES];
}


- (void) addItemViewController:(NewTweetViewController *)controller sendBackNewTweet: (Tweet *)newTweet {
    
    NSLog(@"Got the tweet");
    [self.homeTimeline insertObject:newTweet atIndex:0];
    [self.tableView reloadData];
}



-(void) signOut {
    
    [User logout];
    
}

-(void) newTweet {
    
    NewTweetViewController *ntvc = [[NewTweetViewController alloc] initWithNibName:@"NewTweetViewController" bundle:nil];
    ntvc.delegate = self;
    [self.navigationController pushViewController:ntvc animated:YES];
    
}

-(void)replyWithTweet: (NSNotification *) notification {
    
    NSLog(@"replywithtweet called");
    NewTweetViewController *ntvc = [[NewTweetViewController alloc]init];
    NSDictionary *userInfo = notification.userInfo;
    ntvc.tweet = [userInfo objectForKey:@"tweet"];
    [self.navigationController pushViewController:ntvc animated:YES];
    
}
     


@end
