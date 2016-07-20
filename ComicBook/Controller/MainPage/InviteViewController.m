//
//  InviteViewController.m
//  StickeyBoard
//
//  Created by Ramesh on 04/07/16.
//  Copyright © 2016 Comicing. All rights reserved.
//

#import "InviteViewController.h"
#import <objc/message.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ShareHelper.h"
#import <MessageUI/MessageUI.h>
#import "AppConstants.h"
#import "AppHelper.h"
#import "InviteScore.h"
#import "EmojiHelper.h"
#import "MyEmojiCategory.h"
#import "GlideScrollViewController.h"
#import "OpenCuteStickersGiftBoxViewController.h"

@interface InviteViewController ()<MFMessageComposeViewControllerDelegate>
{
    NSMutableArray* contactList;
}
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (weak, nonatomic) IBOutlet UIButton *btnSkipBack;
@property (weak, nonatomic) IBOutlet UILabel *lblEmoji;
@property (weak, nonatomic) IBOutlet UILabel *lblContactName;
@property (weak, nonatomic) IBOutlet UICountingLabel *lblCurrentScore;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (nonatomic, assign) NSTimer *loadTimer;
@property (nonatomic, assign) NSUInteger contactIndex;
@property (strong, nonatomic) NSArray<MyEmojiCategory *> *emojiCategories;
@property (strong, nonatomic) NSArray<MyEmoji *> *emoji;
@property (weak, nonatomic) IBOutlet UIButton *btnGifBox50;
@property (weak, nonatomic) IBOutlet UIButton *btnGiftBox100;
@property (weak, nonatomic) IBOutlet UIButton *btnGiftBox200;
@property (weak, nonatomic) IBOutlet UIView *mHolderView;

@end

@implementation InviteViewController

- (void)viewDidLoad {
    
    [self prepareView];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:YES];
    
    [self.mHolderView setClipsToBounds:YES];
    [self.mHolderView.layer setMasksToBounds:YES];
    [self.mHolderView.layer setCornerRadius:10];
    
    [self getPhoneContact];
    //[self getFriendsByUserId];
    [self getContactListFromServer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Events

- (IBAction)btnClose:(id)sender {
    
    [self.delegate hideInviteView];
}
- (IBAction)btnInviteClick:(id)sender {
    [self stopTitleAutoLoad];
//    [self updateInviteScore:INVITE_POINT_PERINVITE];
    if ([contactList count] > self.contactIndex) {
        NSDictionary* dct = [contactList objectAtIndex:self.contactIndex];
        [self openMessageComposer:[NSArray arrayWithObjects:[dct objectForKey:@"MobileNumber"], nil]
                      messageText:INVITE_TEXT];
    }
}
- (IBAction)btnSkipClick:(id)sender {
    [self stopTitleAutoLoad];
    [self loadContact];
    [self startTitleAutoLoad];
}
- (IBAction)btnSkipBack:(id)sender {
    [self stopTitleAutoLoad];
    self.contactIndex = self.contactIndex - 1;
    if (self.contactIndex == -1) {
        self.contactIndex = 0;
    }
    [self setContactName];
    [self startTitleAutoLoad];
}
- (IBAction)btnGiftBoxClick50:(id)sender {
    [self btnClose:nil];
    //[self.delegate getStickerListByCategory:ALL CategoryName:@"ALL"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    OpenCuteStickersGiftBoxViewController *controller = (OpenCuteStickersGiftBoxViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"OpenCuteStickersGiftBoxViewController"];
    [self presentViewController:controller animated:YES completion:nil];
    
}
- (IBAction)btnGiftBox100Click:(id)sender {
    [self btnClose:nil];
    //[self.delegate getStickerListByCategory:ALL CategoryName:@"ALL"];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    OpenCuteStickersGiftBoxViewController *controller = (OpenCuteStickersGiftBoxViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"OpenCuteStickersGiftBoxViewController"];
    [self presentViewController:controller animated:YES completion:nil];
}
- (IBAction)btnGiftBox200Click:(id)sender {
    [self btnClose:nil];
    //[self.delegate getStickerListByCategory:ALL CategoryName:@"ALL"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    OpenCuteStickersGiftBoxViewController *controller = (OpenCuteStickersGiftBoxViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"OpenCuteStickersGiftBoxViewController"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)doneClicked:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    GlideScrollViewController *controller = (GlideScrollViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"glidenavigation"];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark Methods

-(void)setContactName{
    if ([contactList count] > self.contactIndex) {
     
        NSDictionary* dct = [contactList objectAtIndex:self.contactIndex];
        self.lblContactName.text = [NSString stringWithFormat:@"Invite %@",[dct objectForKey:@"FullName"]];
        
        self.lblEmoji.text = [NSString stringWithFormat:@"%@",[self getRandomEmojiString]];
    }
}

-(void)loadContact{
    self.contactIndex = self.contactIndex + 1;
    if ([contactList count] == self.contactIndex) {
        self.contactIndex = 0;
    }
    [self setContactName];
}
- (void)startTitleAutoLoad{
    [self.loadTimer invalidate];
    self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                 target:self
                                               selector:@selector(loadContact)
                                               userInfo:nil
                                                repeats:YES];
}

- (void)stopTitleAutoLoad{
    [self.loadTimer invalidate];
    self.loadTimer = nil;
}

-(void)openMessageComposer:(NSArray*)sendNumbers messageText:(NSString*)messageTextValue{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.messageComposeDelegate = self;
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = messageTextValue;
        controller.recipients = sendNumbers;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }}

-(void)prepareView{
    
    self.contactIndex = 0;
    
    /*self.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.borderWidth = 1.0f;
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = true;*/
    
    self.btnInvite.layer.cornerRadius = 5;
    self.btnInvite.layer.masksToBounds = true;
    
    self.btnSkip.layer.cornerRadius = 5;
    self.btnSkip.layer.masksToBounds = true;
    
    self.lblEmoji.text = [NSString stringWithFormat:@"%@",[self getRandomEmojiString]];
    
    self.emojiCategories = [EmojiHelper getEmoji];
    for (MyEmojiCategory* emj in self.emojiCategories) {
        if ([emj.name isEqualToString:DEFAULT_EMOJI]) {
            self.emoji = emj.emoji;
            break;
        }
    }
}

-(NSString*)getRandomEmojiString{
    if (self.emoji && [self.emoji count] > 0) {
        int lowerBound = 0;
        int upperBound = [self.emoji count];
        int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
        return self.emoji[rndValue].emojiString;
    }else{
        return @"\U0001F602";
    }
    
}
-(void)enableScoreRow{
    self.lblCurrentScore.text = [NSString stringWithFormat:@"%.f", [self getCurrentScoreFromDB]];
    float scoreValue = [self getCurrentScoreFromDB];
    if (scoreValue >= INVITE_POINT_200) {
        [self.btnGifBox50 setUserInteractionEnabled:YES];
        [self.btnGiftBox100 setUserInteractionEnabled:YES];
        [self.btnGiftBox200 setUserInteractionEnabled:YES];
    }else if(scoreValue >= INVITE_POINT_100 &&
             scoreValue <= INVITE_POINT_200) {
        [self.btnGifBox50 setUserInteractionEnabled:YES];
        [self.btnGiftBox100 setUserInteractionEnabled:YES];
    }else if(scoreValue >= INVITE_POINT_50 &&
             scoreValue <= INVITE_POINT_100) {
        [self.btnGifBox50 setUserInteractionEnabled:YES];
    }else{
        [self.btnGifBox50 setUserInteractionEnabled:NO];
        [self.btnGiftBox100 setUserInteractionEnabled:NO];
        [self.btnGiftBox200 setUserInteractionEnabled:NO];
    }
}


#pragma mark Adddressbook

-(void)getFriendsByUserId{
    
    ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
    //    cmNetWorking.delegate= self;
    [cmNetWorking userFriendsByUserId:[AppHelper getCurrentLoginId] completion:^(id json,id jsonResposeHeader) {
        [self friendslistResponse:json];
    } ErrorBlock:^(JSONModelError *error) {
        
    }];
}

-(void)friendslistResponse:(NSDictionary *)response
{
    
    //initialize the models
    
    NSArray *friendsFromServer;
    
    if (response[@"data"] != nil)
    {
        friendsFromServer = [UserFriends arrayOfModelsFromDictionaries:response[@"data"]];
    }
    NSMutableArray* phoneContact = [self getPhoneContact];
    
    NSLog(@"Phone Cntactc: %@", phoneContact);
}

#pragma Webservice

-(void)getContactListFromServer{
    
        NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* userDic = [[NSMutableDictionary alloc] init];
    
        [userDic setObject:[AppHelper getCurrentLoginId] forKey:@"user_id"];
        [userDic setObject:contactList forKey:@"contacts"];
        [dataDic setObject:userDic forKey:@"data"];
    
        userDic = nil;
    
        ComicNetworking* cmNetWorking = [ComicNetworking sharedComicNetworking];
    
    
    
     /*temp
        [cmNetWorking postPhoneContactList:dataDic Id:@"659"
                                completion:^(id json,id jsonResposeHeader) {
    
                                    NSLog(@"jsonResposeHeader");
    
                                } ErrorBlock:^(JSONModelError *error) {
    
                                }];*/
    
    
        [cmNetWorking postPhoneContactList:dataDic Id:[AppHelper getCurrentLoginId]
                                completion:^(id json,id jsonResposeHeader) {
    
                                    NSLog(@"jsonResposeHeader");
    
        } ErrorBlock:^(JSONModelError *error) {
            
        }];
        
    
       dataDic = nil;
}

-(NSMutableArray*)getPhoneContact{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        return [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        return [self getContactsWithAddressBook:addressBook];
    }
    return nil;
}

// Get the contacts.
- (NSMutableArray*)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    if (contactList) {
        [contactList removeAllObjects];
        contactList = nil;
    }
    contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        //        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        if (firstName == nil) {
            firstName = (__bridge CFStringRef)@"";
        }
        if (lastName == nil) {
            lastName = (__bridge CFStringRef)@"";
        }
        NSMutableDictionary* dictObj = [[NSMutableDictionary alloc] init];
        
        NSString* FullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
        [dictObj setObject:FullName forKey:@"FullName"];
        //For Phone number
        
        NSString* mobileLabel;
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, j);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
//                [contactNumber addObject:[self removeSpecialChara:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)]];
                mobileLabel = [self removeSpecialChara:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)];
                //       [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"mobile"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
//                [contactNumber addObject:[self removeSpecialChara:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)]];
                mobileLabel = [self removeSpecialChara:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)];
                //                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"mobile"];
                break ;
            }else{
                mobileLabel = nil;
            }
        }
        if (mobileLabel != nil) {
            [dictObj setObject:mobileLabel forKey:@"MobileNumber"];
            [contactList addObject:dictObj];
        }
        
        dictObj = nil;
    }
    [self setContactName];
    [self startTitleAutoLoad];
    [self enableScoreRow];
    return contactList;
}
-(NSString*)removeSpecialChara :(NSString*)phoneNumberString{
    return [[phoneNumberString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
            componentsJoinedByString:@""];
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            NSLog(@"unknown error sending m");
            break;
        case MessageComposeResultSent:
            [self updateInviteScore:INVITE_POINT_PERINVITE];
            break;
        default:
            break;
    }
    [self startTitleAutoLoad];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark DBMethods

-(void)updateInviteScore:(CGFloat)scoreValue{
    
    NSManagedObjectContext *context = [[AppHelper initAppHelper] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"InviteScore"];
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetchRequest error:&error];
    if ([results count] == 0) {
        
        NSManagedObjectContext *context_save = [[AppHelper initAppHelper] managedObjectContext];
        
        NSManagedObject *stickersList = [NSEntityDescription insertNewObjectForEntityForName:@"InviteScore" inManagedObjectContext:context_save];
        [stickersList setValue:[NSString stringWithFormat:@"%.f", scoreValue] forKey:@"scoreValue"];
        
        NSError *error = nil;
        if (![context_save save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }else{
        for (NSManagedObject *managedObject in results) {
            
            NSString* scoreValue = ((InviteScore*)results[0]).scoreValue;
            int fScoreValue = [scoreValue floatValue];
            int oldScoreValue = fScoreValue;
            fScoreValue = fScoreValue + INVITE_POINT_PERINVITE;
            
            [managedObject setValue:[NSString stringWithFormat:@"%.i", fScoreValue] forKey:@"scoreValue"];
            
//            self.lblCurrentScore.text = [NSString stringWithFormat:@"%.f", [self getCurrentScoreFromDB]];
            self.lblCurrentScore.format = @"%d";
            [self.lblCurrentScore countFrom:oldScoreValue to:fScoreValue withDuration:3.0];
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
        }
    }
    [self enableScoreRow];
}

-(float)getCurrentScoreFromDB{
    NSManagedObjectContext *context = [[AppHelper initAppHelper] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"InviteScore"];
    NSError *error      = nil;
    NSArray *results    = [context executeFetchRequest:fetchRequest error:&error];
    if ([results count] == 0) {
        return 0;
    }else{
        NSString* scoreValue = ((InviteScore*)results[0]).scoreValue;
        CGFloat fScoreValue = [scoreValue floatValue];
        return fScoreValue;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - statusbar

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
