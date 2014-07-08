//
//  User.h
//  iosTwitter
//
//  Created by Sudip Shah on 6/25/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

-(User *) initWithDictionary: (NSDictionary *) data;
+(User *) currentUser;
+ (void) logout;

@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSURL * profileURL;
@property (strong, nonatomic) NSString * screenName;
@property int userId;

@end
