//
//  TwitterManager.m
//  TwitterApp
//
//  Created by Hegyi Hajnalka on 11/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import "TwitterManager.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation TwitterManager

+(SLComposeViewController *)composeTweet
{
    SLComposeViewController *tweet = nil;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweet setInitialText:@"Tweeting about..."];
    }
    return tweet;
}

+(void)getRecentTweets
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:TWITTER_HOME_TIMELINE_URL] parameters:[NSDictionary dictionaryWithObjects:@[twitterAccount.username, TWITTER_FETCH_COUNT_VALUE] forKeys: @[TWITTER_USERNAME_KEY, TWITTER_FETCH_COUNT_KEY]]];
                twitterInfoRequest.account = twitterAccount;
                
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
                NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
                NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:twitterInfoRequest.preparedURLRequest
                        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error){
                            if (!error){
                                NSData *jsonResults = [NSData dataWithContentsOfURL: localfile];
                                NSMutableDictionary *tweetList =  [NSJSONSerialization JSONObjectWithData:jsonResults options:NSJSONReadingMutableContainers error:NULL];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[NSNotificationCenter defaultCenter] postNotificationName:TWEETS_RECEIVED_NOTIFICATION object:nil userInfo:tweetList];
                                });
                            }
                        }];
                    [task resume];
                }
            }
    }];
}

@end