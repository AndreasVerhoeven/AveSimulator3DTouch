//
//  DetailViewController.m
//  3DTouchExample
//
//  Created by Andreas Verhoeven on 24-01-16.
//  Copyright © 2016 AveApps. All rights reserved.
//

#import "DetailViewController.h"

@implementation DetailViewController

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
		return 1;
	else
		return self.index / 3 + 1;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 0)
		return @"Name";
	
	return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if(nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	if(indexPath.section == 0)
	{
		cell.textLabel.text = [NSString stringWithFormat:@"Awesome Item #%ld", (long)self.index + 1];
	}
	else
	{
		cell.textLabel.text = [NSString stringWithFormat:@"Detail %ld", (long)indexPath.row + 1];
		cell.detailTextLabel.text = @"Something";
	}
	
	return cell;
}


#pragma UITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
	return [super initWithStyle:UITableViewStyleGrouped];
}

#pragma UIViewController
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.title = @"Detail";
}

- (CGSize)preferredContentSize
{
	return [self.tableView sizeThatFits:CGSizeMake(320, CGFLOAT_MAX)];
}

- (NSArray<id> *)previewActionItems {
	
	// setup a list of preview actions
	UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"Action 1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
		NSLog(@"Action 1 triggered");
	}];
	
	UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Destructive Action" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
		NSLog(@"Destructive Action triggered");
	}];
	
	UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"Selected Action" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
		NSLog(@"Selected Action triggered");
	}];
	
	// add them to an arrary
	NSArray *actions = @[action1, action2, action3];
	
	// and return them
	return actions;
}

@end
