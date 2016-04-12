//
//  FindFriendsView.m
//  ComicApp
//
//  Created by Ramesh on 10/12/15.
//  Copyright © 2015 Ramesh. All rights reserved.
//

#import "FindFriendsViewController.h"
#import "GlideScrollViewController.h"
#import "AppDelegate.h"

#define InviteTagValue 300

@implementation FindFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configView];
    [self bindData];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [super viewWillAppear:animated];
}

#pragma Methods

-(void)configView{
    
    self.searchTextHolderView.layer.borderColor = [[UIColor colorWithHexStr:@"416DB5"] CGColor];
    self.searchTextHolderView.layer.cornerRadius = 15;
    self.searchTextHolderView.layer.masksToBounds = YES;
    self.searchTextHolderView.layer.borderWidth = 2.0f;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"dig up friends by name" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
    self.txtSearch.attributedPlaceholder = str;
    
    [self setTextFont];
    
}

-(void)setTextFont{

    [self.lblHeadText setFont:[UIFont  fontWithName:@"Myriad Roman" size:28]];
    self.lblHeadText.text = @"Find \n Friends";
    [self.btnSkip.titleLabel setFont:[UIFont  fontWithName:@"Myriad Roman" size:28]];

    [UIFont fontWithName:@"Arial-BoldMT" size:17];

    
    // Create the attributes
    NSDictionary *attrs = @{
                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:23],
                            };
    NSDictionary *subAttrs = @{
                               NSFontAttributeName:[UIFont fontWithName:@"Arial-BoldMT" size:23]
                               };
    
    const NSRange range = NSMakeRange(10,4);
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:self.lblCaptionText2.text
                                           attributes:attrs];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [attributedText setAttributes:subAttrs range:range];
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle
                           range:NSMakeRange(0, [self.lblCaptionText2.text length])];
    
    // Set it in our UILabel and we are done!
    [self.lblCaptionText2 setAttributedText:attributedText];
    paragraphStyle = nil;
    attributedText = nil;
    
}

-(void)bindData{
    if (contactNumber) {
        [contactNumber removeAllObjects];
        contactNumber = nil;
    }
    contactNumber = [[NSMutableArray alloc] init];
    
    [self getPhoneContact];
    [self getContactListFromServer];
}

-(NSString*)removeSpecialChara :(NSString*)phoneNumberString{
    return [[phoneNumberString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
            componentsJoinedByString:@""];

}

-(void)getPhoneContact{
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
        [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        [self getContactsWithAddressBook:addressBook];
    }
}

// Get the contacts.
- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    if (contactList) {
        [contactList removeAllObjects];
        contactList = nil;
    }
    contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
            
        }
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, j);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [contactNumber addObject:[self removeSpecialChara:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)]];
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"Phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [contactNumber addObject:[self removeSpecialChara:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)]];
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j) forKey:@"Phone"];
                break ;
            }
            
        }
        [contactList addObject:dOfPerson];
    }
    temContactList = contactList;
    
    [self.contactListTableView reloadData];
}

#pragma TextField Delegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.txtSearch resignFirstResponder];
    
    NSArray* searchArray = [contactList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)", textField.text]];
    
    contactList= nil;
    contactList = [searchArray mutableCopy];
    [self.contactListTableView reloadData];
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    
    textField.text = @"";
    contactList= nil;
    contactList = [temContactList mutableCopy];
    [self.contactListTableView reloadData];
    return NO;
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return contactList.count;
}

// This will tell your UITableView what data to put in which cells in your table.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer = @"FriendsList";
    FindFriendsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"FindFriendsTableCell" owner:self options:nil];
        cell = self.tabCell;
        self.tabCell = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.lblMobileNumber.text = [[contactList objectAtIndex:indexPath.row] objectForKey:@"Phone"];
    cell.lblUserName.text = [[contactList objectAtIndex:indexPath.row] objectForKey:@"name"];
    [cell.btnInvite addTarget:self
                       action:@selector(inviteButtonClick:)
             forControlEvents:UIControlEventTouchUpInside];
    cell.btnInvite.tag = InviteTagValue + indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)inviteButtonClick:(id)sender{
    UIButton* btn =(UIButton*)sender;
    NSInteger indexValue = btn.tag - InviteTagValue ;
    if (contactList && [contactList objectAtIndex:indexValue]) {
        NSMutableDictionary* dict = [contactList objectAtIndex:indexValue];
        NSString* phoneNumber = @"";
        if ([dict objectForKey:@"Phone"]) {
            phoneNumber = [dict objectForKey:@"Phone"];
        }
        [self openMessageComposer:[NSArray arrayWithObjects:phoneNumber, nil] messageText:INVITE_TEXT];
    }
    
}

-(void)openMessageComposer:(NSArray*)sendNumbers messageText:(NSString*)messageTextValue{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = messageTextValue;
        controller.recipients = sendNumbers;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }
}

#pragma MessageDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultSent:
            
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
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
    [cmNetWorking postPhoneContactList:dataDic Id:[AppHelper getCurrentLoginId]
                            completion:^(id json,id jsonResposeHeader) {
        
    } ErrorBlock:^(JSONModelError *error) {
        
    }];
    dataDic = nil;
}

- (IBAction)btnSkipAction:(id)sender {
////    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
////    ContactController *controller = (ContactController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"Contact"];
////    [self.navigationController pushViewController:controller animated:YES];
////    mainStoryboard = nil;
//    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    GlideScrollViewController *controller = (GlideScrollViewController *)[mainStoryboard
//                                                                          instantiateViewControllerWithIdentifier:@"GlideView"];
//    
//    // [self.navigationController presentModalViewController:passcodeNavigationController animated:YES];
////    [self.navigationController presentViewController:controller animated:YES completion:^{
////        
////    }];
//  
//    
//    [self.navigationController pushViewController:controller animated:YES];
//    
//
////    self.viewController = [storyboard instantiateViewControllerWithIdentifier:Identifier];
//    
////    UINavigationController* navCont = [[UINavigationController alloc] initWithRootViewController:controller];
////    [AppDelegate application].window.rootViewController = controller;
//    
//    mainStoryboard = nil;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    GlideScrollViewController *controller = (GlideScrollViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"glidenavigation"];
    [self presentViewController:controller animated:YES completion:nil];
}
@end
