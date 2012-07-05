//
//  LibraryItems.h
//  MpdDispatch
//
//  Created by kernel on 5/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "Song.h"

@interface LibraryItems : NSObject
@property (strong, nonatomic, readonly) NSArray *sections, *sectionIndexTitles;

- (id)initWithSortingTag:(SongTags)tag;
- (Song *)itemForSection:(NSUInteger)section atRow:(NSUInteger)row;
- (NSArray *)itemsForSection:(NSUInteger)section;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
@end
