//
// Created by Bruno Wernimont on 2012
// Copyright 2012 BaseKit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "BKTableModel.h"

#import "UITableViewCell+BaseKit.h"
#import "BKCellAttributeMapping.h"
#import "BKCellMapping.h"
#import "BKCellMapper.h"

#import "UITableViewCell+BaseKit.h"
#import "NSDictionary+BaseKit.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface BKTableModel ()

@property (nonatomic, BK_PROP_RETAIN) NSMutableDictionary *objectMappings;

- (BKCellMapping *)cellMappingForObject:(id)object;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BKTableModel

@synthesize tableView = _tableView;
@synthesize objectMappings = _objectMappings;
@synthesize objectForRowAtIndexPathBlock = _objectForRowAtIndexPathBlock;
@synthesize sectionTitles = _sectionTitles;
@synthesize sections = _sections;
@synthesize items = _items;


////////////////////////////////////////////////////////////////////////////////////////////////////
#if !BK_HAS_ARC
- (void)dealloc {
    self.tableView = nil;
    self.objectMappings = nil;
    self.objectForRowAtIndexPathBlock = nil;
    self.sections = nil;
    self.sectionTitles = nil;
    self.items = nil;
    
    [super dealloc];
}
#endif


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)tableModelForTableView:(UITableView *)tableView {
    BKTableModel *tableModel = [[self alloc] initWithTableView:tableView];
    return BK_AUTORELEASE(tableModel);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTableView:(UITableView *)tableView {
    self = [self init];
    
    if (self) {
        self.tableView = tableView;
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];
    
    if (self) {
        self.objectMappings = [NSMutableDictionary dictionary];
    }
    
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForRowAtIndexPath:indexPath];;
    BKCellMapping *cellMapping = [self cellMappingForObject:object];
    UITableViewCell *cell = nil;
    
    if (nil == cellMapping.nib) {
        cell = [cellMapping.cellClass cellForTableView:self.tableView];
    } else {
        cell = [cellMapping.cellClass cellForTableView:self.tableView fromNib:cellMapping.nib];
    }
    
    [BKCellMapper mapCellAttributeWithMapping:cellMapping object:object cell:cell];
    
#ifndef DEBUG
    if (nil == cell) {
        cell = [UITableViewCell cellForTableView:self.tableView];
    }
#endif
    
    return cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerMapping:(BKCellMapping *)cellMapping {
    NSString *objectClassStringName = NSStringFromClass(cellMapping.objectClass);
    
    NSMutableSet *set = [self.objectMappings objectForKey:objectClassStringName
                                            defaultObject:[NSMutableSet set]];
    
    if (nil == [self.objectMappings objectForKey:cellMapping]) {
        [self.objectMappings setObject:set forKey:objectClassStringName];
    }
    
    [set addObject:cellMapping];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForRowAtIndexPath:indexPath];
    BKCellMapping *cellMapping = [self cellMappingForObject:object];
    
    if (nil != cellMapping.onSelectRowBlock) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        cellMapping.onSelectRowBlock(cell, object, indexPath);
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForRowAtIndexPath:indexPath];
    BKCellMapping *cellMapping = [self cellMappingForObject:object];
    
    CGFloat rowHeight = 0;
    
    if (nil != cellMapping.rowHeightBlock) {
        rowHeight = cellMapping.rowHeightBlock(cellMapping.cellClass, object, indexPath);
    } else if (cellMapping.rowHeight > 0) {
        rowHeight = cellMapping.rowHeight;
    } else {
        rowHeight = self.tableView.rowHeight;
    }
    
    return rowHeight;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForRowAtIndexPath:indexPath];
    BKCellMapping *cellMapping = [self cellMappingForObject:object];
    
    if (nil != cellMapping.willDisplayCellBlock) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        cellMapping.willDisplayCellBlock(cell, object, indexPath);
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadTableItems:(NSArray *)items {
    self.items = [NSMutableArray arrayWithArray:items];
    [self.tableView reloadData];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)objectForRowAtIndexPathWithBlock:(BKObjectForRowAtIndexPathBlock)block {
    self.objectForRowAtIndexPathBlock = block;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (nil != self.objectForRowAtIndexPathBlock) {
        return self.objectForRowAtIndexPathBlock(indexPath);
    } else if (nil != self.items) {
        return [self.items objectAtIndex:indexPath.row];
    }
    
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setters


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellForRowAtIndexPath:indexPath];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForRowAtIndexPath:indexPath];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self willDisplayCell:cell forRowAtIndexPath:indexPath];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectRowAtIndexPath:indexPath];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BKCellMapping *)cellMappingForObject:(id)object {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("be.basekit.cellmapping.tablebodel", NULL);
    BK_UNRETAINED_BLOCK_IVAR BKCellMapping *cellMapping = nil;
    
    dispatch_sync(concurrentQueue, ^{
        NSSet *cellMappings = [BKCellMapper cellMappingsForObject:object mappings:self.objectMappings];
        cellMapping = [BKCellMapper cellMappingForObject:object mappings:cellMappings];
    });
    
    dispatch_release(concurrentQueue);
    
    return cellMapping;
}


@end
