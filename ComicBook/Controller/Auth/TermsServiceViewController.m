//
//  TermsServiceViewController.m
//  ComicBook
//
//  Created by Ramesh on 16/03/16.
//  Copyright © 2016 ADNAN THATHIYA. All rights reserved.
//

#import "TermsServiceViewController.h"
#import "AppConstants.h"

@interface TermsServiceViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TermsServiceViewController

- (void)viewDidLoad {
    [self loadHtmlContent];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadHtmlContent{
    
    NSURL *url = [NSURL URLWithString:TermsAndServiceURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
