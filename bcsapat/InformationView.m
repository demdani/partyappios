//
//  InformationView.m
//  bcsapat
//
//  Created by hallgato on 1/16/14.
//  Copyright (c) 2014 hallgato. All rights reserved.
//

#import "InformationView.h"

@interface InformationView ()
@end

@implementation InformationView
@synthesize clubNameText;

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
	// Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [clubNameText setText:[defaults objectForKey:@"selected"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end