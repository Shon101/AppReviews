//
//  PSEmptyTableViewController
//  PSUIKit
//
//  Created by Charles Gamble on 28/09/2012.
//
//

#import "PSEmptyTableViewController.h"

@implementation PSEmptyTableViewController

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        tableView.dataSource = self;
        tableView.delegate = self;
    }
    return self;
}


#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
