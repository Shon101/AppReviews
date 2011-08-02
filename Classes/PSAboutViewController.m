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

#import "PSAboutViewController.h"
#import "PSHelpViewController.h"
#import "NSString+PSIconFilenames.h"
#import "NSBundle+PSExtras.h"
#import "PSLog.h"


#define kOpenWebsiteURLTagValue         1
#define kOpenReleaseNotesURLTagValue    2
#define kOpenTwitterURLTagValue         3


typedef enum
{
	PSAboutApplicationRow,
	PSAboutVersionRow,
	PSAboutCopyrightRow,
	PSAboutCreditsRow,
	PSAboutWebsiteRow,
	PSAboutTwitterRow,
	PSAboutFeedbackEmailRow,
	PSAboutRecommendEmailRow
} PSAboutRow;


@interface PSAboutViewController ()

@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) UIImage *appIcon;
@property (nonatomic, retain) NSString *appVersion;
@property (nonatomic, retain) NSString *copyright;
@property (nonatomic, retain) NSString *creditsURL;
@property (nonatomic, retain) NSString *websiteURL;
@property (nonatomic, retain) NSString *appURL;
@property (nonatomic, retain) NSString *releaseNotesURL;
@property (nonatomic, retain) NSString *twitterName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *appId;
@property (nonatomic, retain) NSMutableArray *rowTypes;

- (NSString *)pathForIcon;

@end


@implementation PSAboutViewController

@synthesize appName, appIcon, appVersion, copyright, creditsURL, websiteURL, appURL, releaseNotesURL, twitterName, email, appId, applicationNameFontSize, parentViewForConfirmation, rowTypes;


+ (NSString *)appVersion
{
	// In order of preference use PSApplicationSCMVersion, CFBundleShortVersionString, CFBundleVersion.
	NSArray *candidateKeys = [NSArray arrayWithObjects:@"PSApplicationSCMVersion", @"CFBundleShortVersionString", @"CFBundleVersion", nil];
	for (NSString *thisKey in candidateKeys)
	{
		NSString *version = [[NSBundle mainBundle] infoValueForKey:thisKey];
		if (version && [version length] > 0)
			return version;
	}
	// Failed to find any kind of version number.
	return @"";
}

/**
 * Initializer.
 */
- (id)init
{
	return [self initWithParentViewForConfirmation:nil style:UITableViewStyleGrouped];
}

/**
 * Initializer.
 */
- (id)initWithParentViewForConfirmation:(UIView *)parentView
{
	return [self initWithParentViewForConfirmation:parentView style:UITableViewStyleGrouped];
}

/**
 * Initializer.
 */
- (id)initWithStyle:(UITableViewStyle)style
{
	return [self initWithParentViewForConfirmation:nil style:style];
}

/**
 * Designated initializer.
 */
- (id)initWithParentViewForConfirmation:(UIView *)parentView style:(UITableViewStyle)style
{
	NSAssert(style==UITableViewStyleGrouped, @"PSAboutViewController only supports UITableViewStyleGrouped");

    if (self = [super initWithStyle:style])
	{
		self.parentViewForConfirmation = parentView;
    }
    return self;
}

- (void)viewDidLoad
{
	PSLogDebug(@"");
	[super viewDidLoad];

	self.title = NSLocalizedString(@"About", @"About");
	self.appName = [[NSBundle mainBundle] infoValueForKey:@"CFBundleDisplayName"];
	self.appVersion = [PSAboutViewController appVersion];
	self.copyright = [[NSBundle mainBundle] infoValueForKey:@"NSHumanReadableCopyright"];
	self.creditsURL = [[NSBundle mainBundle] infoValueForKey:@"PSCreditsURL"];
	self.websiteURL = [[NSBundle mainBundle] infoValueForKey:@"PSWebsiteURL"];
	self.appURL = [[NSBundle mainBundle] infoValueForKey:@"PSApplicationURL"];
	self.releaseNotesURL = [[NSBundle mainBundle] infoValueForKey:@"PSReleaseNotesURL"];
	self.twitterName = [[NSBundle mainBundle] infoValueForKey:@"PSTwitterName"];
	self.email = [[NSBundle mainBundle] infoValueForKey:@"PSContactEmail"];
	self.appId = [[NSBundle mainBundle] infoValueForKey:@"PSApplicationID"];
	NSString *iconFilePath = [self pathForIcon];
	if (iconFilePath && [iconFilePath length] > 0)
		self.appIcon = [UIImage imageWithContentsOfFile:iconFilePath];
	self.applicationNameFontSize = 28.0;
	// Build an array of row types.
	self.rowTypes = [NSMutableArray array];
	// First row is always app name.
	[rowTypes addObject:[NSNumber numberWithInteger:PSAboutApplicationRow]];
	// Second row is always app version.
	[rowTypes addObject:[NSNumber numberWithInteger:PSAboutVersionRow]];
	// Optional copyright row.
	if (self.copyright && [self.copyright length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutCopyrightRow]];
	// Optional credits row.
	if (self.creditsURL && [self.creditsURL length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutCreditsRow]];
	// Optional website row.
	if (self.websiteURL && [self.websiteURL length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutWebsiteRow]];
	// Optional twitter row.
	if (self.twitterName && [self.twitterName length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutTwitterRow]];
	// Optional feedback row.
	if (self.email && [self.email length]>0)
		[rowTypes addObject:[NSNumber numberWithInteger:PSAboutFeedbackEmailRow]];
	// Final row is always "Send to a friend".
	[rowTypes addObject:[NSNumber numberWithInteger:PSAboutRecommendEmailRow]];
}

- (void)viewDidUnload
{
	PSLogDebug(@"");
	[super viewDidUnload];

	// Release IBOutlets and items which can be recreated in viewDidLoad.
	self.appName = nil;
	self.appVersion = nil;
	self.copyright = nil;
	self.creditsURL = nil;
	self.websiteURL = nil;
	self.appURL = nil;
	self.releaseNotesURL = nil;
	self.twitterName = nil;
	self.email = nil;
	self.appId = nil;
	self.appIcon = nil;
	self.rowTypes = nil;
}

/**
 * Destructor.
 */
- (void)dealloc
{
	PSLogDebug(@"");
	[appName release];
	[appIcon release];
	[appVersion release];
	[copyright release];
	[creditsURL release];
	[websiteURL release];
	[appURL release];
	[releaseNotesURL release];
	[twitterName release];
	[email release];
	[appId release];
	[parentViewForConfirmation release];
	[rowTypes release];
    [super dealloc];
}

- (NSString *)pathForIcon
{
	NSString *iconFile = [[NSBundle mainBundle] infoValueForKey:@"PSAboutIconFile"];

	NSArray *filenames = [iconFile preferredIconFilenames];
	for (NSString *filename in filenames)
	{
		NSString *iconFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"png"];
		if (iconFilePath)
			return iconFilePath;
	}

	return nil;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSAboutRow rowType = (PSAboutRow) [[rowTypes objectAtIndex:indexPath.row] integerValue];
	switch (rowType)
	{
		case PSAboutVersionRow:
		case PSAboutCreditsRow:
		case PSAboutWebsiteRow:
		case PSAboutTwitterRow:
		case PSAboutFeedbackEmailRow:
		case PSAboutRecommendEmailRow:
			return indexPath;
		default:
			return nil;
	}

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSAboutRow rowType = (PSAboutRow) [[rowTypes objectAtIndex:indexPath.row] integerValue];
	if (rowType == PSAboutApplicationRow)
		return 67.0;
	return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIActionSheet *sheet = nil;

	PSAboutRow rowType = (PSAboutRow) [[rowTypes objectAtIndex:indexPath.row] integerValue];
	switch (rowType)
	{
		case PSAboutCreditsRow:
		{
			// Create the credits view controller.
			PSHelpViewController *creditsViewController = [[[PSHelpViewController alloc] initWithNibName:@"PSHelpView" bundle:nil] autorelease];
			creditsViewController.hidesBottomBarWhenPushed = YES;
			creditsViewController.viewTitle = @"Credits";
			// Set the content.
			NSString *creditsFile = [self.creditsURL stringByDeletingPathExtension];
			NSString *creditsExt = [self.creditsURL pathExtension];
			NSString *contentPath = [[NSBundle mainBundle] pathForResource:creditsFile ofType:creditsExt];
			NSAssert2(contentPath != nil, @"Could not locate resource file %@.%@", creditsFile, creditsExt);
			NSURL *contentURL = [NSURL fileURLWithPath:contentPath];
			creditsViewController.contentURL = contentURL;
			// Show the content.
			[self.navigationController pushViewController:creditsViewController animated:YES];
			break;
		}
		case PSAboutWebsiteRow:
		{
			sheet = [[UIActionSheet alloc] initWithTitle:websiteURL delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Visit Website", @"Visit Website"), nil];
			sheet.tag = kOpenWebsiteURLTagValue;
			break;
		}
		case PSAboutTwitterRow:
		{
			sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"@%@", twitterName] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Visit Twitter", @"Visit Twitter"), nil];
			sheet.tag = kOpenTwitterURLTagValue;
			break;
		}
		case PSAboutVersionRow:
		{
			sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"View Release Notes", @"View Release Notes"), nil];
			sheet.tag = kOpenReleaseNotesURLTagValue;
			break;
		}
		case PSAboutFeedbackEmailRow:
		{
			// Check that email is configured on device
			if ([MFMailComposeViewController canSendMail])
			{
				MFMailComposeViewController *mailVC = [[[MFMailComposeViewController alloc] init] autorelease];
				mailVC.mailComposeDelegate = self;
				[mailVC setSubject:[NSString stringWithFormat:@"%@ Feedback (version %@)", appName, appVersion]];
				[mailVC setToRecipients:[NSArray arrayWithObject:email]];
				[self presentModalViewController:mailVC animated:YES];
			}
			else
			{
				// Email not configured on device.
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
																message:NSLocalizedString(@"Email has not been configured on this device!", @"Email has not been configured on this device!")
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
			break;
		}
		case PSAboutRecommendEmailRow:
		{
			// Check that email is configured on device
			if ([MFMailComposeViewController canSendMail])
			{
				NSString *subject = [NSString stringWithFormat:NSLocalizedString(@"I thought you might be interested in %@", @"I thought you might be interested in %@"), appName];
				NSString *body = nil;
				if (appId && [appId length] > 0)
				{
					// We have the appId, provide a link to the app's page in the App Store.
					NSURL *homeURL = [NSURL URLWithString:appURL];
					if ([homeURL scheme] == nil)
					{
						// No URL scheme was specified, so assume http://
						homeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", appURL]];
					}

					body = [NSString stringWithFormat:@"%@:\nhttp://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@\n\n%@:\n%@", NSLocalizedString(@"Available in the App Store", @"Available in the App Store"), appId, NSLocalizedString(@"For more information",@"For more information"), [homeURL absoluteString]];
				}
				else if (appURL)
				{
					// We don't have the appId, provide a link to the app's home page.
					NSURL *homeURL = [NSURL URLWithString:appURL];
					if ([homeURL scheme] == nil)
					{
						// No URL scheme was specified, so assume http://
						homeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", appURL]];
					}
					body = [homeURL absoluteString];
				}
				else
				{
					// We don't have the appId or the app's home page, provide a link to the company's home page.
					NSURL *homeURL = [NSURL URLWithString:websiteURL];
					if ([homeURL scheme] == nil)
					{
						// No URL scheme was specified, so assume http://
						homeURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", websiteURL]];
					}
					body = [homeURL absoluteString];
				}
				MFMailComposeViewController *mailVC = [[[MFMailComposeViewController alloc] init] autorelease];
				mailVC.mailComposeDelegate = self;
				[mailVC setSubject:subject];
				[mailVC setMessageBody:body isHTML:NO];
				[self presentModalViewController:mailVC animated:YES];
			}
			else
			{
				// Email not configured on device.
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
																message:NSLocalizedString(@"Email has not been configured on this device!", @"Email has not been configured on this device!")
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"Dismiss")
													  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
			break;
		}
		default:
		{
			// Deselect table row.
			[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
			break;
		}
	}

	if (sheet)
	{
		// Determine what the parent view is, for the UIActionSheet.
		UIView *parentView = self.parentViewForConfirmation;
		if (parentView == nil)
			parentView = self.tableView;

		if ([parentView isKindOfClass:[UITabBar class]])
		{
			[sheet showFromTabBar:(UITabBar *)parentView];
		}
		else if ([parentView isKindOfClass:[UIToolbar class]])
		{
			[sheet showFromToolbar:(UIToolbar *)parentView];
		}
		else
		{
			[sheet showInView:parentView];
		}
		[sheet release];
	}
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rowTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *kPSSimpleCellIdentifier = @"PSSimpleCellIdentifier";
    static NSString *kPSTitleValueTableCellID = @"PSTitleValueTableCellID";
    UITableViewCell *cell = nil;

	PSAboutRow rowType = (PSAboutRow) [[rowTypes objectAtIndex:indexPath.row] integerValue];
	switch (rowType)
	{
		case PSAboutApplicationRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSSimpleCellIdentifier];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPSSimpleCellIdentifier] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.font = [UIFont boldSystemFontOfSize:applicationNameFontSize];
			cell.textLabel.text = appName;
			cell.imageView.image = appIcon;
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		}
		case PSAboutVersionRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Version", @"Version");
			cell.detailTextLabel.text = appVersion;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutCopyrightRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.text = NSLocalizedString(@"Copyright", @"Copyright");
			cell.detailTextLabel.text = copyright;
			cell.accessoryType = UITableViewCellAccessoryNone;
			break;
		}
		case PSAboutCreditsRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Credits", @"Credits");
			cell.detailTextLabel.text = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutWebsiteRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Website", @"Website");
			cell.detailTextLabel.text = websiteURL;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutTwitterRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Twitter", @"Twitter");
			cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", twitterName];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutFeedbackEmailRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Email", @"Email");
			cell.detailTextLabel.text = email;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
		case PSAboutRecommendEmailRow:
		{
			// Obtain the cell.
			cell = [tableView dequeueReusableCellWithIdentifier:kPSTitleValueTableCellID];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kPSTitleValueTableCellID] autorelease];
			}
			// Configure the cell.
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.textLabel.text = NSLocalizedString(@"Send To Friend", @"Send To Friend");
			cell.detailTextLabel.text = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		}
	}
    return cell;
}


#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	PSLogDebug(@"buttonIndex=%d: (%@)", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
	// Deselect table row.
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	PSLogDebug(@"buttonIndex=%d: (%@)", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
	NSURL *url = nil;

	switch (actionSheet.tag)
	{
		case kOpenWebsiteURLTagValue:
		{
			if (buttonIndex == 0)
			{
				// Ensure app data is saved before app quits.
				url = [NSURL URLWithString:websiteURL];
				if ([url scheme] == nil)
				{
					// No URL scheme was specified, so assume http://
					url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", websiteURL]];
				}

				if (url)
				{
					PSLogDebug(@"Opening URL: %@", [url description]);
					[[UIApplication sharedApplication] openURL:url];
				}
			}
			break;
		}
		case kOpenTwitterURLTagValue:
		{
			if (buttonIndex == 0)
			{
				// Ensure app data is saved before app quits.
				url = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", twitterName]];
				if (url)
				{
					PSLogDebug(@"Opening URL: %@", [url description]);
					[[UIApplication sharedApplication] openURL:url];
				}
			}
			break;
		}
		case kOpenReleaseNotesURLTagValue:
		{
			if (buttonIndex == 0)
			{
				// Ensure app data is saved before app quits.
				url = [NSURL URLWithString:releaseNotesURL];
				if ([url scheme] == nil)
				{
					// No URL scheme was specified, so assume http://
					url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", releaseNotesURL]];
				}

				if (url)
				{
					PSLogDebug(@"Opening URL: %@", [url description]);
					[[UIApplication sharedApplication] openURL:url];
				}
			}
			break;
		}
	}
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if (error)
	{
		PSLogError(@"Error sending email: %@", [error localizedDescription]);
	}

	// Dismiss mail interface.
	[self dismissModalViewControllerAnimated:YES];
}

@end

