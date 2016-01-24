//
//  MainViewController.m
//  3DTouchExample
//
//  Created by Andreas Verhoeven on 24-01-16.
//  Copyright © 2016 AveApps. All rights reserved.
//

#import "MainViewController.h"
#import "DetailViewController.h"

@interface MainViewController () <UIViewControllerPreviewingDelegate>
@end

@implementation MainViewController

- (DetailViewController*)ave_detailViewControllerForIndexPath:(NSIndexPath*)indexPath
{
	DetailViewController* viewController = [DetailViewController new];
	viewController.index = indexPath.row;
	return viewController;
}

#pragma mark UIViewControllerPreviewingDelegate

- (UIViewController*)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
	NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)previewingContext.sourceView];
	
	return [self ave_detailViewControllerForIndexPath:indexPath];
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
	[self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 10;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if(nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		if(self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
		{
			[self registerForPreviewingWithDelegate:self sourceView:cell];
		}
	}
	
	cell.textLabel.text = [NSString stringWithFormat:@"Awesome Item #%ld", (long)indexPath.row + 1];
	
	return cell;
}

#pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.navigationController pushViewController:[self ave_detailViewControllerForIndexPath:indexPath] animated:YES];
}

#pragma mark ViewController
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.navigationItem.title = @"Main";
	
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.1149 green:0.6308 blue:0.951 alpha:1.0];
}

@end
