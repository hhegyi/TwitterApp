//
//  TweetsTableViewController.h
//  TwitterApp
//
//  Created by Hegyi Hajnalka on 11/01/16.
//  Copyright © 2016 Hegyi Hajnalka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetsTableViewController : UITableViewController <UISearchResultsUpdating>

- (IBAction)postTweet:(UIBarButtonItem *)sender;

@end
