//
//  TwitterClient.m
//  iosTwitter
//
//  Created by Sudip Shah on 6/25/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "TwitterClient.h"


@implementation TwitterClient

+ (TwitterClient *) instance {
    
    static TwitterClient *instance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com"] consumerKey:@"krCQeRVdr2zYMWeahuMb4x6NL" consumerSecret:@"NFplgwcaPvPwMs30fKlK6lK36138sDe2adkXttEG2Ei2H9PypF"];
    });
    
    return instance;
}

- (void) login {
    [self.requestSerializer removeAccessToken];
    
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"POST" callbackURL:[NSURL URLWithString:@"cptwitter://oauth"] scope:nil success:^(BDBOAuthToken *requestToken) {
        NSLog(@"Got the request token");
        NSString *authURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
        
    } failure:^(NSError *error) {
        NSLog(@"failure: %@", [error description]);
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not get request token" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }];
}


- (AFHTTPRequestOperation *) homeTimelineWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    return [self GET:@"1.1/statuses/home_timeline.json" parameters:@{@"contributor_details" : @(YES), @"include_my_retweet": @(YES)} success:success failure:failure];
}

- (AFHTTPRequestOperation *) postNewTweet: (NSString*)tweet success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [self POST:@"1.1/statuses/update.json" parameters:@{@"status": tweet} success:success failure:failure];
    
}

- (AFHTTPRequestOperation *) postReplyTweet: (NSString*)tweet replyTo:(NSString *)userId success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [self POST:@"1.1/statuses/update.json" parameters:@{@"status":tweet, @"in_reply_to_status_id":userId} success:success failure:failure];
    
}

- (AFHTTPRequestOperation *)retweetPost: (NSString*) retweetId success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [self POST:[NSString stringWithFormat:@"1.1/statuses/retweet/%@.json",retweetId] parameters:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)favoriteTweet: (NSString*) tweetId success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [self POST:@"1.1/favorites/create.json" parameters:@{@"id" : tweetId } success:success failure:failure];
}


- (AFHTTPRequestOperation *)unFavoriteTweet: (NSString*) tweetId success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [self POST:@"1.1/favorites/destroy.json" parameters:@{@"id" : tweetId } success:success failure:failure];
}


- (AFHTTPRequestOperation *) destroyTweet: (NSString *) tweetId success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [self POST:[NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweetId] parameters:nil success:success failure:failure];
}


@end
