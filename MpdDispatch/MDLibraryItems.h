//
//  LibraryItems.h
//  MpdDispatch
//
//  Created by kernel on 5/07/12.
//  Copyright (c) 2012 DemoApp. All rights reserved.
//

#import "MDSong.h"

@interface MDLibraryItems : NSObject
@property (strong, nonatomic, readonly) NSArray *sections, *sectionIndexTitles;

- (id)initWithSortingTag:(SongTags)tag;
- (MDSong *)itemForSection:(NSUInteger)section atRow:(NSUInteger)row;

- (NSArray *)sectionItemsForSection:(NSUInteger)section;
- (NSArray *)itemsForSection:(NSUInteger)section;

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
@end
