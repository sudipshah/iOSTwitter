//
//  TDLAppDelegate.m
//  iosTwitter
//
//  Created by Sudip Shah on 6/25/14.
//  Copyright (c) 2014 Sudip. All rights reserved.
//

#import "TDLAppDelegate.h"
#import "LoginViewController.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"
#import "User.h"

#define ColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation NSURL (dictionaryFromQueryString)

- (NSDictionary *)dictionaryFromQueryString
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    NSArray *pairs = [[self query] componentsSeparatedByString:@"&"];
    
    for(NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dictionary setObject:val forKey:key];
    }
    
    return dictionary;
}

@end

@implementation TDLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectRootViewController) name:@"UserLoggedOut" object:nil];
    
    [self selectRootViewController];
    
    [[UINavigationBar appearance] setBarTintColor:ColorFromRGB(0x64a5e6)];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if([[TwitterClient instance] isAuthorized]) {
        [User currentUser];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void) selectRootViewController {
    
    if ([[TwitterClient instance] isAuthorized]) {
        
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TweetsViewController alloc]init]];
        
    } else {
        
        self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
    }
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url.scheme isEqualToString:@"cptwitter"])
    {
        if ([url.host isEqualToString:@"oauth"])
        {
            NSDictionary *parameters = [url dictionaryFromQueryString];
            if (parameters[@"oauth_token"] && parameters[@"oauth_verifier"]){
                
                TwitterClient *twitterClient = [TwitterClient instance];
                [twitterClient fetchAccessTokenWithPath:@"/oauth/access_token" method:@"POST" requestToken:[BDBOAuthToken tokenWithQueryString:url.query] success:^(BDBOAuthToken *accessToken) {
                    NSLog(@"Access token");
                    [twitterClient.requestSerializer saveAccessToken:accessToken];
                    
                    [User currentUser];
                    
                    [self selectRootViewController];
                    
                } failure:^(NSError *error) {
                    NSLog(@"access token error");
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not get access token" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }];
                
                
            }
            
        }
        return YES;
    }
    return NO;
}

@end
