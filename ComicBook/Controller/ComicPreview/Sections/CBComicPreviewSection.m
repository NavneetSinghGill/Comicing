//
//  CBComicPreviewSection.m
//  ComicBook
//
//  Created by Atul Khatri on 07/12/16.
//  Copyright © 2016 Providence. All rights reserved.
//

#import "CBComicPreviewSection.h"
#import "CBComicPreviewCell.h"

#define kCellIdentifier @"ComicPreviewCell"
#define kCellHeight [UIScreen mainScreen].bounds.size.height

@implementation CBComicPreviewSection
- (CBBaseTableViewCell*)cellWithTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath{
    self.tableView= tableView;
    CBComicPreviewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"CBComicPreviewCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
    }
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (NSInteger)numberOfRowsInSection{
    return 1;
}
@end
