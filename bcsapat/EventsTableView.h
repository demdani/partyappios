//
//  EventsTableView.h
//  bcsapat
//
//  Created by hallgato on 1/26/14.
//  Copyright (c) 2014 hallgato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsTableView : UITableViewController<UIAlertViewDelegate>

@property NSMutableArray *eventsArray;

- (IBAction)back:(id)sender;
@end
