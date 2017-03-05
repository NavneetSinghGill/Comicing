//
//  ViewController.h
//  ShareSticker
//
//  Created by Ramesh on 09/01/16.
//  Copyright © 2016 comicapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareHelper.h"
#import "UIImage+Image.h"

@interface StickerShareViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *stickerViewHolder;
@property (weak, nonatomic) IBOutlet UIButton *btnTextStickers;
@property (nonatomic, strong) UIImage *imgSelectedSticker;
-(void)addShareSticker:(UIImage*)imgSticker;
@end
