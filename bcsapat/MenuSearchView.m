//
//  MenuSearchClass.m
//  bcsapat
//
//  Created by hallgato on 1/9/14.
//  Copyright (c) 2014 hallgato. All rights reserved.
//

#import "MenuSearchView.h"
#import "ProfileFirstView.h"
#import "NotificationsView.h"
#import "FavouritesView.h"
#import "MyPlacesView.h"
#import "LoginView.h"
#import "AddNewClubView.h"
#import "Session.h"

@interface MenuSearchView ()

@end

@implementation MenuSearchView
@synthesize clubType,checkButton,checkBoxSelected;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [checkButton setBackgroundImage:[UIImage imageNamed:@"1389999128_unchecked_checkbox.png"]
                           forState:UIControlStateNormal];
    [checkButton setBackgroundImage:[UIImage imageNamed:@"1389999143_checked_checkbox.png"]
                        forState:UIControlStateSelected];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//a navigation bar jobb felső sarkában lévő gomb megnyomására az action sheet megjelenítése
- (IBAction)isChecked:(id)sender {
    checkBoxSelected = !checkBoxSelected;
    [checkButton setSelected:checkBoxSelected];
}

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Mégse"
                                              destructiveButtonTitle:nil otherButtonTitles:@"Kedvencek", @"Hozzáadás",@"Helyeim",@"Értesítések",@"Profilom",@"Kijelentkezés", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:[UIApplication sharedApplication].keyWindow];
    popupQuery.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-popupQuery.frame.size.height, [UIScreen mainScreen].bounds.size.width, popupQuery.frame.size.height);
}


//action sheet gombjai váltanak a nézetek között
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
        //ugrás a kedvencekre
        /*FavouritesView *FavouritesView=
        [self.storyboard instantiateViewControllerWithIdentifier:@"FavouritesView"];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:FavouritesView];
        [self presentViewController:navController animated:YES completion:nil];*/
        
        [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
        [[Session getInstance]testAddString:@"Ibolya"];
        
        UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
        
        tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController: tabBar animated: YES completion:nil];
        
        
        
    } else if (buttonIndex == 1) {
        
        //új klubb hozzáadása nézet
        AddNewClubView *AddNewClubView=
        [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewClubView"];
        [self presentViewController:AddNewClubView animated:YES completion:nil];
        
    } else if (buttonIndex == 2) {
       
        //helyeim nézet
        MyPlacesView *MyPlacesView=
        [self.storyboard instantiateViewControllerWithIdentifier:@"MyPlacesView"];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:MyPlacesView];
        [self presentViewController:navController animated:YES completion:nil];
        
        
        
        
    } else if (buttonIndex == 3) {
        
        //értesítések nézet
        NotificationsView *NotificationsView=
        [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationsView"];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:NotificationsView];
        [self presentViewController:navController animated:YES completion:nil];
        
    }
    else if (buttonIndex == 4) {
        
        //ugrás a profilom nézetbe
        ProfileFirstView *ProfileFirstView=
        [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileFirstView"];
        [self presentViewController:ProfileFirstView animated:YES completion:nil];
    }
    else if (buttonIndex == 5) {
        
        //ugrás a bejelentkezés nézetre
        [Session deleteSession];
        LoginView *LoginView=
        [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self presentViewController:LoginView animated:YES completion:nil];
    }
    else if (buttonIndex == 6) {
       // NSLog(@"Mégse");
    }  
}


@end
