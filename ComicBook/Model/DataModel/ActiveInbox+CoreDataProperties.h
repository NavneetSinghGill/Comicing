//
//  RecentSticky+CoreDataProperties.h
//  StickeyBoard
//
//  Created by Ramesh on 19/06/16.
//  Copyright © 2016 Comicing. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ActiveInbox.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActiveInbox (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *comic_delivery_id;
@property (nullable, nonatomic, retain) BOOL *isRead;
@property (nullable, nonatomic, retain) NSString *share_type;
@property (nullable, nonatomic, retain) NSString *user_id;
@end

NS_ASSUME_NONNULL_END
