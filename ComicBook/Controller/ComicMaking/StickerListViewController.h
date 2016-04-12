//
//  StickerListViewController.h
//  ShareSticker
//
//  Created by Ramesh on 09/01/16.
//  Copyright © 2016 comicapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StickerShareViewController.h"

@interface StickerListViewController : UICollectionViewController
{
    NSIndexPath* lastSelectedIndexPath;
}
@property(nonatomic,strong) NSMutableArray *stickers;
@property (nonatomic, strong) StickerShareViewController *parentViewController;
@end
