//
//  MenuMapView.m
//  bcsapat
//
//  Created by hallgato on 1/10/14.
//  Copyright (c) 2014 hallgato. All rights reserved.
//

#import "MenuMapView.h"
#import "ProfileTableView.h"
#import "NotificationsView.h"
#import "LoginView.h"
#import "MyAnnotation.h"
#import "Session.h"
#import "Club.h"
#import "AddNewClubTableView.h"
#import "User.h"
#import "AdminTableView.h"
#import "PendingViewController.h"

@interface MenuMapView ()



@end

@implementation MenuMapView
@synthesize map,initialLocation,container;



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
    
    [map setDelegate:self];
    
    //map.showsUserLocation=YES;
    
    
    
   locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    
    /*CLLocationCoordinate2D userlocation;
    userlocation.latitude = locationManager.location.coordinate.latitude;
    userlocation.longitude = locationManager.location.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(userlocation, 2000, 2000);
    [map setRegion:viewRegion animated: YES];*/
    
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:[[Session getInstance]getUserLocation] completionHandler:^(NSArray* placemarks, NSError* error){
        for (CLPlacemark* aPlacemark in placemarks)
        {
            CLLocationCoordinate2D theCoordinate;
            
            theCoordinate.latitude=aPlacemark.location.coordinate.latitude;
            theCoordinate.longitude=aPlacemark.location.coordinate.longitude;
            
    
            
            MKPointAnnotation *needle = [[MKPointAnnotation alloc] init];
            needle.coordinate = theCoordinate;
            needle.title =@"Itt vagyok most!";
            needle.subtitle=[[Session getInstance]getUserLocation];
            [map addAnnotation:needle];
        }
    }];
    
    

    
    
    
    

    
    
    //az amind minden helyet lát
    /*for (int i=0; i<[[[Session getInstance]getSearchViewCLubs]count]; ++i) {
        if ([[[Session getInstance]getActualUser]getType]==1) {
            [self setLocations:[[[Session getInstance]getSearchViewCLubs]objectAtIndex:i]];
        }
        //a user csak az elfogadott helyeket látja
        else if ([[[Session getInstance]getSelectedClubAtIndex:i]getApproved]==1)
        [self setLocations:[[[Session getInstance]getSearchViewCLubs]objectAtIndex:i]];
    }*/
   
    for (int i=0; i<[[[Session getInstance]getSearchViewCLubs]count]; ++i) {
            [self setLocations:[[[Session getInstance]getSearchViewCLubs]objectAtIndex:i]];
    }

    
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in map.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [map setVisibleMapRect:zoomRect animated:YES];
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//action sheet gombjai váltanak a nézetek között
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //user ág
    if ([[[Session getInstance]getActualUser]getType]==0) {
        
        if (buttonIndex == 0) {
            
            //lista frissitése közeli helyekre
            
            if (locationManager.location.coordinate.latitude==0 && locationManager.location.coordinate.longitude==0) {
                [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
                NSMutableArray * inputClubList = [[[Session getInstance] getCommunication] getClubsFromCityName:@"Debrecen"];
                [[Session getInstance] setSearchViewCLubs:inputClubList];
                
                NSLog(@"input elotte: %d",[inputClubList count]);
                inputClubList=nil;
                NSLog(@"input utana: %d",[inputClubList count]);
                
                UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
                
                tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController: tabBar animated: YES completion:nil];
                
                
            }
            else{
                
                //lista frissitése közeli helyekre
                
                [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
                NSString *lat=[NSString stringWithFormat:@"%f",locationManager.location.coordinate.latitude];
                NSString *lon=[NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude];
                
                
                //a meghívandó url string-be behegesztjük a kordinátákat
                NSString *urlstring=[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=false",lat,lon];
                
                //az url stringből létrehozunk egy urlt
                NSURL *url = [NSURL URLWithString:urlstring];
                
                //NSLog(@"%@",urlstring);
                
                //az url-ből visszakapunk egy egy json-t
                NSData *jsonData = [NSData dataWithContentsOfURL:url];
                NSError *error;
                
                //json-t átadjuk egy szótárnak
                NSDictionary *decoded= [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                
                NSString* address=[[[decoded objectForKey:@"results"]objectAtIndex:0]objectForKey:@"formatted_address"];
                [[Session getInstance]setUserLocation:address];
                
                //        NSLog(@"%@",[[[[[decoded objectForKey:@"results"]objectAtIndex:0]objectForKey:@"address_components"]objectAtIndex:2]objectForKey:@"long_name"]);
                
                NSString* cityName=[[[[[decoded objectForKey:@"results"]objectAtIndex:0]objectForKey:@"address_components"]objectAtIndex:2]objectForKey:@"long_name"];
                
                NSMutableArray * inputClubList = [[[Session getInstance] getCommunication] getClubsFromCityName:cityName];
                [[Session getInstance] setSearchViewCLubs:inputClubList];
                
                
                NSLog(@"input elotte: %d",[inputClubList count]);
                inputClubList=nil;
                NSLog(@"input utana: %d",[inputClubList count]);
                
                UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
                
                tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController: tabBar animated: YES completion:nil];
            }
            
        }
        
        else if (buttonIndex == 1) {
            
            
            //lista frissítése kedvencek nézetre
            [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
            int user_id = [[[Session getInstance] getActualUser] getID];
            NSMutableArray * favoriteClubList = [[[Session getInstance] getCommunication] getFavoriteClubsFromUserId:user_id];
            [[Session getInstance] setSearchViewCLubs:favoriteClubList];
            
            UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
            
            tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController: tabBar animated: YES completion:nil];
            
            
            
        }   else if (buttonIndex == 3) {
            //új klubb hozzáadása
            
            AddNewClubTableView *AddNewClubTableView=
            [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewClubTableView"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:AddNewClubTableView];
            [self presentViewController:navController animated:YES completion:nil];
            
        }   else if (buttonIndex == 2) {
            
            //lista frissítése saját helyekre
            [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
            
            int user_id = [[[Session getInstance] getActualUser] getID];
            NSMutableArray * ownClubList = [[[Session getInstance] getCommunication] getOwnedClubsFromUserId:user_id];
            [[Session getInstance] setSearchViewCLubs:ownClubList];
            
            
            UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
            
            tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController: tabBar animated: YES completion:nil];
            
            
            
            
        }
        else if (buttonIndex == 4) {
            
            //profilom nézet
            ProfileTableView *ProfileTableView=
            [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileTableView"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:ProfileTableView];
            [self presentViewController:navController animated:YES completion:nil];
        }
        else if (buttonIndex == 5) {
            //kijelentkezés
            
            [Session deleteSession];
            LoginView *LoginView=
            [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
            [self presentViewController:LoginView animated:YES completion:nil];
        }
        else if (buttonIndex == 6) {
            // NSLog(@"Mégse");
        }
    }
    //admin ág
    else{
        if (buttonIndex == 0) {
            
            //lista frissitése közeli helyekre
            
            if (locationManager.location.coordinate.latitude==0 && locationManager.location.coordinate.longitude==0) {
                [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
                NSMutableArray * inputClubList = [[[Session getInstance] getCommunication] getClubsFromCityName:@"Debrecen"];
                [[Session getInstance] setSearchViewCLubs:inputClubList];
                
                NSLog(@"input elotte: %d",[inputClubList count]);
                inputClubList=nil;
                NSLog(@"input utana: %d",[inputClubList count]);
                
                UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
                
                tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController: tabBar animated: YES completion:nil];
                
                
            }
            else{
                
                //lista frissitése közeli helyekre
                
                [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
                NSString *lat=[NSString stringWithFormat:@"%f",locationManager.location.coordinate.latitude];
                NSString *lon=[NSString stringWithFormat:@"%f",locationManager.location.coordinate.longitude];
                
                
                //a meghívandó url string-be behegesztjük a kordinátákat
                NSString *urlstring=[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=false",lat,lon];
                
                //az url stringből létrehozunk egy urlt
                NSURL *url = [NSURL URLWithString:urlstring];
                
                //NSLog(@"%@",urlstring);
                
                //az url-ből visszakapunk egy egy json-t
                NSData *jsonData = [NSData dataWithContentsOfURL:url];
                NSError *error;
                
                //json-t átadjuk egy szótárnak
                NSDictionary *decoded= [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                
                NSString* address=[[[decoded objectForKey:@"results"]objectAtIndex:0]objectForKey:@"formatted_address"];
                [[Session getInstance]setUserLocation:address];
                
                //        NSLog(@"%@",[[[[[decoded objectForKey:@"results"]objectAtIndex:0]objectForKey:@"address_components"]objectAtIndex:2]objectForKey:@"long_name"]);
                
                NSString* cityName=[[[[[decoded objectForKey:@"results"]objectAtIndex:0]objectForKey:@"address_components"]objectAtIndex:2]objectForKey:@"long_name"];
                
                NSMutableArray * inputClubList = [[[Session getInstance] getCommunication] getClubsFromCityName:cityName];
                [[Session getInstance] setSearchViewCLubs:inputClubList];
                
                
                NSLog(@"input elotte: %d",[inputClubList count]);
                inputClubList=nil;
                NSLog(@"input utana: %d",[inputClubList count]);
                
                UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
                
                tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController: tabBar animated: YES completion:nil];
            }
            
        }
        
        else if (buttonIndex == 1) {
            
            
            //lista frissítése kedvencek nézetre
            [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
            int user_id = [[[Session getInstance] getActualUser] getID];
            NSMutableArray * favoriteClubList = [[[Session getInstance] getCommunication] getFavoriteClubsFromUserId:user_id];
            [[Session getInstance] setSearchViewCLubs:favoriteClubList];
            
            UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
            
            tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController: tabBar animated: YES completion:nil];
            
            
            
        }   else if (buttonIndex == 3) {
            //új klubb hozzáadása
            
            AddNewClubTableView *AddNewClubTableView=
            [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewClubTableView"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:AddNewClubTableView];
            [self presentViewController:navController animated:YES completion:nil];
            
        }   else if (buttonIndex == 2) {
            
            //lista frissítése saját helyekre
            [[[Session getInstance]getSearchViewCLubs]removeAllObjects];
            
            int user_id = [[[Session getInstance] getActualUser] getID];
            NSMutableArray * ownClubList = [[[Session getInstance] getCommunication] getOwnedClubsFromUserId:user_id];
            [[Session getInstance] setSearchViewCLubs:ownClubList];
            
            
            UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"mainMenuTabBar"];
            
            tabBar.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController: tabBar animated: YES completion:nil];
            
            
            
            
        }
        else if (buttonIndex == 4) {
            
            //profilom nézet
            ProfileTableView *ProfileTableView=
            [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileTableView"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:ProfileTableView];
            [self presentViewController:navController animated:YES completion:nil];
        }
        else if (buttonIndex == 5) {
            //Jóváhagyások
            
            PendingViewController *AdminTableView=
            [self.storyboard instantiateViewControllerWithIdentifier:@"PendingViewController"];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:AdminTableView];
            [self presentViewController:navController animated:YES completion:nil];
            
        }
        else if (buttonIndex == 6) {
            //kijelentkezés
            
            [Session deleteSession];
            LoginView *LoginView=
            [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
            [self presentViewController:LoginView animated:YES completion:nil];
        }
        
        else if (buttonIndex == 7) {
            // mégse
        }
    }
}



- (void)setLocations:(Club *)club {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:[club getAddress] completionHandler:^(NSArray* placemarks, NSError* error){
        for (CLPlacemark* aPlacemark in placemarks)
        {
            CLLocationCoordinate2D theCoordinate;
            theCoordinate.latitude=aPlacemark.location.coordinate.latitude;
            theCoordinate.longitude=aPlacemark.location.coordinate.longitude;
            MyAnnotation *annotation=[[MyAnnotation alloc]init];
            annotation.coordinate=theCoordinate;
            annotation.title=[club getClubName];
            annotation.subtitle=[club getAddress];
            annotation.approved=[club getApproved];
            //[container addObject:annotation];
            [map addAnnotation:annotation];
            
            
            MKMapRect zoomRect = MKMapRectNull;
            for (id <MKAnnotation> annotation in map.annotations)
            {
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
                zoomRect = MKMapRectUnion(zoomRect, pointRect);
            }
            [map setVisibleMapRect:zoomRect animated:YES];
        }
    }];

}

/*- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if ( !initialLocation )
    {
        self.initialLocation = userLocation.location;
        
        MKCoordinateRegion region;
        region.span = MKCoordinateSpanMake(0.15, 0.2);
        region.center = mapView.userLocation.coordinate;
        //region.span = MKCoordinateSpanMake(0.1, 0.1);
        
         region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
     
    }
}*/


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc]     initWithAnnotation:annotation reuseIdentifier:@"pinLocation"];
    
    newAnnotation.canShowCallout = YES;
    
    /*if(([annotation isKindOfClass:[MKUserLocation class]]))
        { //newAnnotation.pinColor = MKPinAnnotationColorGreen;
            ((MKUserLocation *)annotation).title = @"Itt vagyok most!";
            return nil;
        }
    else
    {newAnnotation.pinColor = MKPinAnnotationColorRed;
     newAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }*/
    
    
    //az én helyzetem színe lil
    if ([annotation.title isEqualToString:@"Itt vagyok most!"]) {
        newAnnotation.pinColor = MKPinAnnotationColorGreen;
    }
    //a nem elfogadott helyek színe piros
    /*else if ([(MyAnnotation*)annotation getApproved]==0){
        newAnnotation.pinColor = MKPinAnnotationColorRed;
        newAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    //az elfogadott helyek színe zölt*/
    else{
        newAnnotation.pinColor = MKPinAnnotationColorPurple;
        newAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    return newAnnotation;

}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

   /* int index=[mapView.annotations indexOfObject:view.annotation]; //össze-vissza dobálja az indexeket
    [[Session getInstance]setSelectedIndex:index];
    NSLog(@"%d",index);*/
 
    //ahol az annotációban lévő név és cím egyezik a session-ban lévővel, a sessionból az az idex kell
    MyAnnotation* ann=(MyAnnotation*)view.annotation;
    for (int i=0; i<[[[Session getInstance]getSearchViewCLubs]count]; ++i) {
        if ([ann.title isEqualToString:[[[[Session getInstance]getSearchViewCLubs]objectAtIndex:i]getClubName]]
            && [ann.subtitle isEqualToString:[[[[Session getInstance]getSearchViewCLubs]objectAtIndex:i]getAddress]]) {
            
            //aktuális club adatainak lekérése
            int club_id = [[[[Session getInstance] getSearchViewCLubs] objectAtIndex:i] getIdentifier];
            Club *fullClub = [[[Session getInstance]getCommunication] getEverythingFromClubId:club_id];
            
            Club * club1 = [[[Session getInstance] getSearchViewCLubs] objectAtIndex:i];            
            [club1 setRatings:[[[Session getInstance]getCommunication] getRatingsFromClubID:club_id]];
            [club1 setAddress: [ fullClub getAddress ]];
            [club1 setPhoneNumber: [ fullClub getPhoneNumber ]];
            [club1 setEmail: [fullClub getEmail]];
            [club1 setDescription:[fullClub getDescription]];
            [club1 setType:[fullClub getType]];
            
            [[Session getInstance]setSelectedIndex:i];
        }
    }
    
    UITabBarController *tabBar = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"ClubTabBar"];
    
    
    tabBar.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController: tabBar animated: YES completion:nil];
}



/*-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
   MyAnnotation *annotation = (MyAnnotation *)view.annotation;
    NSInteger *yourIndex = [annotation]
    
    if ([view.annotation isKindOfClass:[MyAnnotation class]]) {
        MyAnnotation *annot = view.annotation;
        int index = [container indexOfObject:annot];
        NSLog(@"%d",index);
    }
}*/

//a navigation bar jobb felső sarkában lévő gomb megnyomására az action sheet megjelenítése
- (IBAction)showActionSheet:(id)sender {
    //admin action sheet
    if ([[[Session getInstance]getActualUser]getType]==1) {
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Mégse"
                                                  destructiveButtonTitle:nil otherButtonTitles:@"Közeli helyek",@"Kedvencek", @"Helyeim",@"Hely hozzáadása",@"Profilom",@"Jóváhagyások",@"Kijelentkezés", nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [popupQuery showInView:[UIApplication sharedApplication].keyWindow];
        popupQuery.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-popupQuery.frame.size.height, [UIScreen mainScreen].bounds.size.width, popupQuery.frame.size.height);
    }
    //user action sheet
    else{
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Mégse"
                                                  destructiveButtonTitle:nil otherButtonTitles:@"Közeli helyek",@"Kedvencek", @"Helyeim",@"Hely hozzáadása",@"Profilom",@"Kijelentkezés", nil];
        
        popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [popupQuery showInView:[UIApplication sharedApplication].keyWindow];
        popupQuery.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-popupQuery.frame.size.height, [UIScreen mainScreen].bounds.size.width, popupQuery.frame.size.height);
    }
    
}




/*- (void)purgeMapMemory
{
    // Switching map types causes cache purging, so switch to a different map type
    map.mapType = MKMapTypeStandard;
    [map removeFromSuperview];
    map = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // This is for a bug in MKMapView for iOS6
    [self purgeMapMemory];
}*/


/*- (void)applyMapViewMemoryHotFix{
    
    switch (self.map.mapType) {
        case MKMapTypeHybrid:
        {
            self.map.mapType = MKMapTypeStandard;
        }
            
            break;
        case MKMapTypeStandard:
        {
            self.map.mapType = MKMapTypeHybrid;
        }
            
            break;
        default:
            break;
    }
    self.map.showsUserLocation = NO;
    self.map.delegate = nil;
    [self.map removeFromSuperview];
    self.map = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self applyMapViewMemoryHotFix];
}*/

@end
