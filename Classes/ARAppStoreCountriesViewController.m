//
//	Copyright (c) 2008-2011, AppReviews
//	http://github.com/gambcl/AppReviews
//	http://www.perculasoft.com/appreviews
//	All rights reserved.
//
//	This software is released under the terms of the BSD License.
//	http://www.opensource.org/licenses/bsd-license.php
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//	* Redistributions of source code must retain the above copyright notice, this
//	  list of conditions and the following disclaimer.
//	* Redistributions in binary form must reproduce the above copyright notice,
//	  this list of conditions and the following disclaimer
//	  in the documentation and/or other materials provided with the distribution.
//	* Neither the name of AppReviews nor the names of its contributors may be used
//	  to endorse or promote products derived from this software without specific
//	  prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//	IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//	OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ARAppStoreCountriesViewController.h"
#import "ARAppStoreReviewsViewController.h"
#import "ARAppStoreApplication.h"
#import "ARAppStore.h"
#import "ARAppStoreUpdateOperation.h"
#import "AppReviewsAppDelegate.h"
#import "ARAppStoreTableCell.h"
#import "PSImageView.h"
#import "PSRatingView.h"
#import "PSCountView.h"
#import "PSLog.h"


@interface ARAppStoreCountriesViewController ()

@property (nonatomic, retain) NSMutableArray *enabledStores;
@property (nonatomic, retain) NSMutableArray *displayedStores;
@property (nonatomic, retain) UIBarButtonItem *updateButton;
@property (nonatomic, retain) UILabel *remainingLabel;
@property (nonatomic, retain) UIActivityIndicatorView *remainingSpinner;
@property (nonatomic, retain) ARAppStoreReviewsViewController *appStoreReviewsViewController;
@property (retain) ARAppStoreApplicationDetailsImporter *detailsImporter;
@property (retain) ARAppStoreApplicationReviewsImporter *reviewsImporter;
@property (nonatomic, retain) NSMutableArray *storeIdsProcessed;
@property (nonatomic, retain) NSMutableArray *storeIdsRemaining;
@property (nonatomic, retain) NSMutableArray *unavailableStoreNames;
@property (nonatomic, retain) NSMutableArray *failedStoreNames;

- (void)updateEnabledStores;
- (void)updateDisplayedStores;

@end

@implementation ARAppStoreCountriesViewController

@synthesize appStoreApplication, enabledStores, displayedStores, updateButton, remainingLabel, remainingSpinner, appStoreReviewsViewController, detailsImporter, reviewsImporter, storeIdsProcessed, storeIdsRemaining, unavailableStoreNames, failedStoreNames;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithNibName:nibName bundle:nibBundle])
	{
		self.title = @"Countries";
		self.appStoreReviewsViewController = nil;
		self.detailsImporter = nil;
		self.reviewsImporter = nil;

		// Add the Update button.
		self.updateButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateAllDetails:)] autorelease];
		self.navigationItem.rightBarButtonItem = self.updateButton;

		// Set the back button title.
		self.navigationItem.backBarButtonItem =	[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Countries", @"Countries") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];

		// Create a label for toolbar.
		remainingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		remainingLabel.textColor = [UIColor whiteColor];
		remainingLabel.backgroundColor = [UIColor clearColor];
		remainingLabel.text = @"NNN remaining";
		remainingLabel.textAlignment = UITextAlignmentRight;
		UIFont *labelFont = [UIFont systemFontOfSize:14.0];
		remainingLabel.font = labelFont;
		CGSize labelSize = [remainingLabel.text sizeWithFont:labelFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, 16.0) lineBreakMode:UILineBreakModeTailTruncation];
		remainingLabel.frame = CGRectMake(0.0, 0.0, labelSize.width, labelSize.height);
		remainingLabel.hidden = YES;

		// Create a spinner for toolbar.
		remainingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		remainingSpinner.hidesWhenStopped = YES;

		self.storeIdsProcessed = [NSMutableArray array];
		self.storeIdsRemaining = [NSMutableArray array];
		self.unavailableStoreNames = [NSMutableArray array];
		self.failedStoreNames = [NSMutableArray array];
		self.enabledStores = [NSMutableArray array];
		self.displayedStores = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[appStoreApplication release];
	[updateButton release];
	[remainingLabel release];
	[remainingSpinner release];
	[appStoreReviewsViewController release];
	[detailsImporter release];
	[reviewsImporter release];
	[storeIdsProcessed release];
	[storeIdsRemaining release];
	[unavailableStoreNames release];
	[failedStoreNames release];
	[enabledStores release];
	[displayedStores release];
    [super dealloc];
}

- (void)viewDidLoad
{
	PSLogDebug(@"");
	[super viewDidLoad];

	// Create a "house" button for toolbar.
	UIBarButtonItem *visitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"house.png"] style:UIBarButtonItemStylePlain target:self action:@selector(visit:)];

	// Create a flexible space for toolbar.
	UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	// Create a label for toolbar.
	UIBarButtonItem *labelItem = [[UIBarButtonItem alloc] initWithCustomView:remainingLabel];

	// Create a spinner for toolbar.
	UIBarButtonItem *spinnerItem = [[UIBarButtonItem alloc] initWithCustomView:remainingSpinner];

	// Set the items for this view's toolbar.
	NSArray *items = [NSArray arrayWithObjects:visitButton, spaceItem, labelItem, spinnerItem, nil];
	[visitButton release];
	[spaceItem release];
	[labelItem release];
	[spinnerItem release];
	self.toolbarItems = items;
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	self.toolbarItems = nil;
	self.appStoreReviewsViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self updateEnabledStores];
	[self updateDisplayedStores];

	[self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdated:) name:kARAppStoreUpdateOperationDidStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdated:) name:kARAppStoreUpdateOperationDidFinishNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreReviewsUpdated:) name:kARAppStoreUpdateOperationDidFailNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self.navigationController setToolbarHidden:YES animated:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:kARAppStoreUpdateOperationDidStartNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kARAppStoreUpdateOperationDidFinishNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kARAppStoreUpdateOperationDidFailNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)setAppStoreApplication:(ARAppStoreApplication *)inAppStoreApplication
{
	[inAppStoreApplication retain];
	[appStoreApplication release];
	appStoreApplication = inAppStoreApplication;

	if (appStoreApplication.name)
		self.title = appStoreApplication.name;
	else
		self.title = appStoreApplication.appIdentifier;
}

- (void)updateAllDetails:(id)sender
{
	// User tapped the Update button - queue up the download operations.

	// First cancel all current/pending operations for this app.
	[appStoreApplication cancelAllOperations];
	[appStoreApplication suspendAllOperations];

	// Create array of operations.
	NSMutableArray *ops = [NSMutableArray array];
	for (ARAppStore *appStore in enabledStores)
	{
		// Only add this store if it is enabled for this app.
		if (appStore.enabled)
		{
			ARAppStoreApplicationDetails *details = [[ARAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:appStore];
			details.state = ARAppStoreStatePending;
			ARAppStoreUpdateOperation *op = [[ARAppStoreUpdateOperation alloc] initWithApplicationDetails:details];

			// Make sure that the "home store" for this app has a high priority in the queue.
			if ([appStore.storeIdentifier isEqualToString:appStoreApplication.defaultStoreIdentifier])
			{
				[op setQueuePriority:NSOperationQueuePriorityHigh];
				[ops insertObject:op atIndex:0];
			}
			else
			{
				[op setQueuePriority:NSOperationQueuePriorityNormal];
				[ops addObject:op];
			}
			[op release];
		}
	}

	// Add operations to the queue for processing.
	for (int i = 0; i < [ops count]; i++)
	{
		ARAppStoreUpdateOperation *op = [ops objectAtIndex:i];

		// Wait for the previous operation to complete.
		if (i > 0)
		{
			[op addDependency:[ops objectAtIndex:(i-1)]];
		}
		// Add operation to the operation queue for this app.
		[appStoreApplication addUpdateOperation:op];
	}

	// Refresh table.
	[self.tableView reloadData];
	// Update toolbar items.
	remainingLabel.text = [NSString stringWithFormat:@"%d remaining", appStoreApplication.updateOperationsCount];
	[remainingSpinner startAnimating];
	// Start processing.
	[appStoreApplication resumeAllOperations];
}

// Called on main thread after Start/Finish/Fail.
- (void)appStoreReviewsUpdated:(NSNotification *)notification
{
	PSLog(@"Received notification: %@", notification.name);
	ARAppStoreApplicationDetails *lastStoreProcessed = (ARAppStoreApplicationDetails *) [notification object];

	// Only pay attention to this notification if it is for our current application.
	if ([lastStoreProcessed.appIdentifier isEqualToString:appStoreApplication.appIdentifier])
	{
		// Update table to show any store's reviews that were just completed.
		[self updateDisplayedStores];

		// Fill in missing app details if we have them available in last processed store reviews.
		if ((appStoreApplication.name==nil || appStoreApplication.company==nil) && [[notification name] isEqualToString:kARAppStoreUpdateOperationDidFinishNotification])
		{
			if (lastStoreProcessed.appName && [lastStoreProcessed.appName length] > 0)
			{
				appStoreApplication.name = lastStoreProcessed.appName;
				self.title = lastStoreProcessed.appName;
			}

			if (lastStoreProcessed.appCompany && [lastStoreProcessed.appCompany length] > 0)
			{
				appStoreApplication.company = lastStoreProcessed.appCompany;
			}
		}
	}
}

- (void)updateEnabledStores
{
	// First refresh enabled stores from settings.
	[[ARAppReviewsStore sharedInstance] refreshAppStores];

	// Build up a list of enabled stores.
	[enabledStores removeAllObjects];
	for (ARAppStore *store in [[ARAppReviewsStore sharedInstance] appStores])
	{
		if (store.enabled)
		{
			[enabledStores addObject:store];
		}
	}
}

- (void)updateDisplayedStores
{
	// Updates the tableview and takes account of the hideEmptyCountries setting.
	[displayedStores removeAllObjects];
	for (ARAppStore *appStore in enabledStores)
	{
		ARAppStoreApplicationDetails *details = [[ARAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:appStore];
		// Only add store if it has any ratings/reviews OR we are not hiding empty stores.
		if ((details && (details.reviewCountAll + details.reviewCountCurrent + details.ratingCountAll + details.ratingCountCurrent) > 0) ||
			([[NSUserDefaults standardUserDefaults] boolForKey:@"hideEmptyCountries"] == NO))
		{
			[displayedStores addObject:appStore];
		}
	}

	// Refresh table.
	[self.tableView reloadData];
	// Update toolbar items.
	if (appStoreApplication.updateOperationsCount > 0)
	{
		remainingLabel.text = [NSString stringWithFormat:@"%d remaining", appStoreApplication.updateOperationsCount];
		remainingLabel.hidden = NO;
		[remainingSpinner startAnimating];
	}
	else
	{
		remainingLabel.hidden = YES;
		[remainingSpinner stopAnimating];
	}
}

- (void)userDefaultsChanged:(NSNotification *)notification
{
	PSLogDebug(@"");
	[self updateEnabledStores];
	[self updateDisplayedStores];
}

- (void)visit:(id)sender
{
	NSUInteger cancelButtonIndex = 1;
	NSString *sheetTitle = (appStoreApplication.name ? appStoreApplication.name : appStoreApplication.appIdentifier);
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Visit App Store", nil];

	[appStoreApplication hydrate];
	NSString *defaultStoreIdentifier = appStoreApplication.defaultStoreIdentifier;
	if (defaultStoreIdentifier && [defaultStoreIdentifier length] > 0)
	{
		ARAppStore *store = [[ARAppReviewsStore sharedInstance] storeForIdentifier:defaultStoreIdentifier];
		if (store)
		{
			ARAppStoreApplicationDetails *details = [[ARAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:store];
			if (details)
			{
				[details hydrate];
				if (details.companyURL && [details.companyURL length] > 0)
				{
					[sheet addButtonWithTitle:@"Visit Company URL"];
					cancelButtonIndex++;
				}

				if (details.supportURL && [details.supportURL length] > 0)
				{
					[sheet addButtonWithTitle:@"Visit Support URL"];
					cancelButtonIndex++;
				}
			}
		}
	}

	[sheet addButtonWithTitle:@"Cancel"];
	sheet.cancelButtonIndex = cancelButtonIndex;
	[sheet showFromToolbar:[self.navigationController toolbar]];
	[sheet release];
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Display reviews for store.
	ARAppStore *appStore = [displayedStores objectAtIndex:indexPath.row];
	ARAppStoreApplicationDetails *appStoreDetails = [[ARAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:appStore];
	// Lazily create reviews view controller.
	if (self.appStoreReviewsViewController == nil)
	{
		ARAppStoreReviewsViewController *viewController = [[ARAppStoreReviewsViewController alloc] initWithStyle:UITableViewStylePlain];
		self.appStoreReviewsViewController = viewController;
		[viewController release];
	}
	[appStoreDetails hydrate];
	self.appStoreReviewsViewController.appStoreDetails = appStoreDetails;
	[self.navigationController pushViewController:self.appStoreReviewsViewController animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [displayedStores count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AppStoreCell";

    ARAppStoreTableCell *cell = (ARAppStoreTableCell *) [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[ARAppStoreTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell
	ARAppStore *appStore = [displayedStores objectAtIndex:indexPath.row];
	cell.nameLabel.text = appStore.name;

	// iOS 4 requires no extension and handles Retina display support, but iOS 3 requires extension.
	UIImage *flagImage = [UIImage imageNamed:appStore.storeIdentifier];
	cell.flagView.image = (flagImage ? flagImage : [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", appStore.storeIdentifier]]);

	ARAppStoreApplicationDetails *storeDetails = [[ARAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:appStore];
	if (storeDetails)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.countView.count = storeDetails.reviewCountAll;
		cell.ratingView.rating = storeDetails.ratingAll;
		cell.state = storeDetails.state;
		if (storeDetails.ratingCountAll > 0)
			cell.ratingCountLabel.text = [NSString stringWithFormat:@"in %d rating%@", storeDetails.ratingCountAll, (storeDetails.ratingCountAll==1?@"":@"s")];
		else
			cell.ratingCountLabel.text = nil;

		if (storeDetails.hasNewRatings)
		{
			[cell.ratingCountLabel setTextColor:[UIColor colorWithRed:142.0/255.0 green:217.0/255.0 blue:255.0/255.0 alpha:1.0]];
		}
		else
		{
			[cell.ratingCountLabel setTextColor:[UIColor colorWithRed:0.55 green:0.6 blue:0.7 alpha:1.0]];
		}

		if (storeDetails.hasNewReviews)
		{
			[cell.countView setLozengeColor:[UIColor colorWithRed:142.0/255.0 green:217.0/255.0 blue:255.0/255.0 alpha:1.0]];
		}
		else
		{
			[cell.countView setLozengeColor:nil];
		}
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.countView.count = 0;
		cell.ratingView.rating = 0.0;
		[cell.countView setLozengeColor:nil];
		cell.state = ARAppStoreStateDefault;
	}

    return cell;
}


#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// Deselect table row.
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	PSLogDebug(@"Clicked on button %d: %@", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);

	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		NSURL *targetURL = nil;
		[appStoreApplication hydrate];

		if (buttonIndex == 0)
		{
			// Build URL to app store.
			targetURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@", appStoreApplication.appIdentifier]];
		}
		else
		{
			// Build URL to company/support site.
			NSString *defaultStoreIdentifier = appStoreApplication.defaultStoreIdentifier;
			if (defaultStoreIdentifier && [defaultStoreIdentifier length] > 0)
			{
				ARAppStore *store = [[ARAppReviewsStore sharedInstance] storeForIdentifier:defaultStoreIdentifier];
				if (store)
				{
					ARAppStoreApplicationDetails *details = [[ARAppReviewsStore sharedInstance] detailsForApplication:appStoreApplication inStore:store];
					if (details)
					{
						NSMutableArray *URLs = [NSMutableArray array];
						[details hydrate];
						if (details.companyURL && [details.companyURL length] > 0)
							[URLs addObject:details.companyURL];

						if (details.supportURL && [details.supportURL length] > 0)
							[URLs addObject:details.supportURL];

						NSInteger urlIndex = buttonIndex - 1;
						if ((urlIndex >= 0) && (urlIndex < [URLs count]))
						{
							targetURL = [NSURL URLWithString:[URLs objectAtIndex:urlIndex]];
						}
					}
				}
			}
		}

		if (targetURL)
			[[UIApplication sharedApplication] openURL:targetURL];
	}
}

@end

