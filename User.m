//
//  User.m
//  iosTwitter
//
//  Created by Sudip Shah on 6/25/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

@implementation User

+ (void) logout {
    
    [[TwitterClient instance] deauthorize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserLoggedOut" object:nil];
}

+ (User *) currentUser {
    
    static dispatch_once_t once;
	static User *user;
    
    dispatch_once(&once, ^{
        user = [[User alloc]init];
    });
        
    if (!user.userId) {
        
        [[TwitterClient instance] GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"currentUser responseObject: %@", responseObject);
            user = [user initWithDictionary:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
    }
    
    return user;
}


-(User *) initWithDictionary: (NSDictionary *) data {
    
    User * user = [[User alloc]init];
    user.name = data[@"name"];
    user.profileURL = [NSURL URLWithString:data[@"profile_image_url"]];
    user.screenName = data[@"screen_name"];
    user.userId = [data[@"id"] integerValue];
    
    return user;
    
}

@end
