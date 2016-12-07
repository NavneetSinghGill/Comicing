//
//  CBComicPreviewItemVC.h
//  ComicBook
//
//  Created by Atul Khatri on 07/12/16.
//  Copyright © 2016 Providence. All rights reserved.
//

#import "CBBaseCollectionViewController.h"
#import "CBComicItemModel.h"

@interface CBComicPreviewItemVC : CBBaseCollectionViewController
- (void)addComicItem:(CBComicItemModel*)comicItem;
@end
