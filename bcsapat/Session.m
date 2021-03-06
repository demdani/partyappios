//
//  Session.m
//  bcsapat
//
//  Created by hallgato on 1/13/14.
//  Copyright (c) 2014 hallgato. All rights reserved.
//

#import "Session.h"
#import "User.h"
#import "MyDatabase.h"
#include<unistd.h>
#include<netdb.h>


@implementation Session


static Session * _instance = nil;

+(Session *)getInstance{
    @synchronized([Session class]){
        if (_instance == nil) {
            [[self alloc] init];
            return _instance;
        }
    }
    return _instance;
}

+(void)deleteSession{
    _instance=nil;
}


-(void)setEventTime:(NSString *)time{
    eventTime=time;
}

-(NSString *)getEventTime{
    return eventTime;
}


-(void)setSelectedEventIndex:(int)index{
    selectedEvent=index;
}

-(int)getSelectedEventIndex{
    return selectedEvent;
}

-(void)setMenuItemCategory:(NSString *)category{
    menuItemCategory=category;
}

-(NSString *)getMenuItemCategory{
    return menuItemCategory;
}

-(void)setSelectedRatingIndex:(int)index{
    selectedRating=index;
}

-(int)getSelectedRatingIndex{
    return selectedRating;
}

-(void)setMenuItemIndex:(int)itemIndex{
    menuItemIndex=itemIndex;
}

-(int)getMenuItemIndex{
    return menuItemIndex;
}

-(void)setSelectedIndex:(int)index{
    SelectedIndex=index;
}

-(int)getSelectedIndex{
    return SelectedIndex;
}

-(User *)getActualUser{
    return actualUser;
}

-(void)setActualUser:(User *)user{
    actualUser = user;
}

-(NSMutableArray *) getSearchViewCLubs{
    return searchViewCLubs;
}

-(void)addClub:(Club *)club{
    [searchViewCLubs addObject:club];
}

-(void)testAddString:(NSString*)string{
    [searchViewCLubs addObject:string];
}

-(Club*)getSelectedClubAtIndex:(int)index{
    return [searchViewCLubs objectAtIndex:index];
}

-(void)logArray{
    for (int i=0; i<[searchViewCLubs count]; ++i) {
        NSLog(@"%@",[searchViewCLubs objectAtIndex:i]);
    }
}


-(BOOL)isNetworAvaiable{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL){
       // NSLog(@"-> no connection!\n");
        isOnline=NO;
    }
    else{
       // NSLog(@"-> connection established!\n");
        isOnline=YES;
    }
    return isOnline;
}

-(MyDatabase *)getDatabse{
    return databaseConnection;
}

-(Communication *)getCommunication{
    return actualCommunication;
}

-(void)setUserLocation:(NSString *)location{
    userLocation=location;
}

-(NSString *)getUserLocation{
    return userLocation;
}

-(NSString *)getClubTypeForPicker{
    return clubTypeForPicker;
}

-(void)setClubTypeForPicer:(NSString *)picker{
    clubTypeForPicker=picker;
}

+(id)alloc {
    @synchronized([Session class]) {
        NSAssert(_instance == nil, @"oops... Mar van ilyen peldany");
        _instance = [super alloc];
        return _instance;
    }
    return nil;
}

-(id)init {
    if (self = [super init]) {
        NSArray* paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString *path =[documentsDirectory stringByAppendingPathComponent:@"partyapp.db"];
        
        databaseConnection = [[MyDatabase alloc] initWithPath:path];
        actualCommunication = [[Communication alloc] init];
        searchViewCLubs = [[NSMutableArray alloc]init];
        clubTypeForPicker=@"Bármelyik";
        musicType=@"Zene típusa";
        image=[[UIImage alloc]init];
        menuItemCategory=@"Kategória";
        eventTime=@"Esemény időpontja";
        birthday=@"";
    }
    return self;
}

-(NSString *)getBirthday{
    return birthday;
}

-(void)setBirthDay:(NSString *)birthday_{
    birthday=birthday_;
}

-(void)setSearchViewCLubs:(NSMutableArray *)inputClubsList{
    NSLog(@"elotte: %d",[searchViewCLubs count]);
    [searchViewCLubs addObjectsFromArray:inputClubsList];
    NSLog(@"utana: %d",[searchViewCLubs count]);
}

-(void)setMusicType:(NSString *)music{
    musicType=music;
}

-(NSString *)getMusicType{
    return musicType;
}

-(void)setImage:(int)picid{
    image=picid;
}

-(int)getImage{
    return image;
}

@end
