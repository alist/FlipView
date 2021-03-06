/*
 This module is licensed under the MIT license.
 
 Copyright (C) 2011 by raw engineering
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
//
//  WallViewController.m
//  FlipView
//
//  Created by Reefaq Mohammed on 16/07/11.
 
//

#import "WallViewController.h"
#import "TitleAndTextView.h"
#import "Layout5.h"
#import "Layout6.h"
#import "Layout7.h"
#import "Layout8.h"

#import "Layout1.h"
#import "Layout2.h"
#import "Layout3.h"
#import "Layout4.h"

#import "UIViewExtention.h"
#import "AFKPageFlipper.h"
#import "FullScreenView.h"
#import "FooterView.h"
#import "HeaderView.h"

#import "ClothingModel.h"
#import "Clothing.h"
#import "SBJson.h"
#import "Session.h"
#import "Me.h"

@implementation WallViewController

@synthesize viewControlerStack,gestureRecognizer,wallTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
   
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
    {
		[self.view setBackgroundColor:[UIColor whiteColor]];
		isInFullScreenMode = FALSE;
		
		messageArrayCollection = [[NSMutableArray alloc] init];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSString *surl = [@"http://api.clossit.com/api/User.aspx?q=suggestions&results=24&key=" stringByAppendingString:[Session getUser].apiKey];
        NSLog(surl);
        NSURL *url = [NSURL URLWithString:surl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
       
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        NSArray *items = [parser objectWithString:json_string error:nil];
        for(NSDictionary *item in items)
        {
            
            Clothing* a = [[Clothing alloc] initFromDictionary:[item objectForKey:@"clothing"]];
            ClothingModel* clothingModel = [[ClothingModel alloc] initWithClothing:a];
            [messageArrayCollection addObject:clothingModel];
        }
		
		[self buildPages:messageArrayCollection];
		
		flipper = [[AFKPageFlipper alloc] initWithFrame:self.view.bounds];
		flipper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		flipper.dataSource = self;
		[self.view addSubview:flipper];
		
    }
    
    return self;
}

- (int)getRandomNumber:(int)from to:(int)to {
	return (int)from + random() % (to-from+1);
}


-(void)buildPages:(NSArray*)messageArray {
	
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	viewControlerStack = [[NSMutableArray alloc] init]; 
	
	int remainingMessageCount = 0;
	int totalMessageCount = [messageArray count];
	
	remainingMessageCount = totalMessageCount;
	
    while(remainingMessageCount > 5) {
        int i = [self getRandomNumber:1 to:5];
        remainingMessageCount -= i;
		[viewControlerStack addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    /*
    int numOfGroup = totalMessageCount /5;
	for (int i=1; i<=numOfGroup; i++) {
		
		remainingMessageCount = totalMessageCount - (i * 5);
		int randomNumber = [self getRandomNumber:5 to:8];
		
		[viewControlerStack addObject:[NSString stringWithFormat:@"%d",randomNumber]];
	}
     */
	
	if (remainingMessageCount > 0) {
		[viewControlerStack addObject:[NSString stringWithFormat:@"%d",remainingMessageCount]];
	}

	
}


#pragma mark -
#pragma mark Data source implementation



- (NSInteger) numberOfPagesForPageFlipper:(AFKPageFlipper *)pageFlipper {
	return [viewControlerStack count];
}

- (UIView *) viewForPage:(NSInteger) page inFlipper:(AFKPageFlipper *) pageFlipper {

  	LayoutViewExtention* layoutToReturn = nil;
	NSInteger layoutNumber = [[viewControlerStack objectAtIndex:page-1] intValue];
    
    int count = [[viewControlerStack objectAtIndex:page-1] intValue];
	int rangeFrom = 0;
	BOOL shouldContinue = TRUE;
    
    for(int i=0; i<page-1; i++) {
        rangeFrom += [[viewControlerStack objectAtIndex:i] intValue];
    }
	if (shouldContinue) {
		
		NSRange rangeForView = NSMakeRange(rangeFrom, count);
		
		NSArray* messageArray= [messageArrayCollection subarrayWithRange:rangeForView];
		
		NSMutableDictionary* viewDictonary = [[NSMutableDictionary alloc] init];
		TitleAndTextView* view1forLayout;
		TitleAndTextView* view2forLayout;
		TitleAndTextView* view3forLayout;
		TitleAndTextView* view4forLayout;
		TitleAndTextView* view5forLayout;
		for (int i = 0; i < [messageArray count]; i++) {
			if (i == 0) {
				view1forLayout = [[TitleAndTextView alloc] initWithClothingModel:(ClothingModel*)[messageArray objectAtIndex:i]];
				[viewDictonary setObject:view1forLayout forKey:@"view1"];
			}
			if (i == 1) {
				view2forLayout = [[TitleAndTextView alloc] initWithClothingModel:(ClothingModel*)[messageArray objectAtIndex:i]];

				[viewDictonary setObject:view2forLayout forKey:@"view2"];
			}
			if (i == 2) {
				view3forLayout = [[TitleAndTextView alloc] initWithClothingModel:(ClothingModel*)[messageArray objectAtIndex:i]];
				[viewDictonary setObject:view3forLayout forKey:@"view3"];
			}
			if (i == 3) {
				view4forLayout = [[TitleAndTextView alloc] initWithClothingModel:(ClothingModel*)[messageArray objectAtIndex:i]];
				[viewDictonary setObject:view4forLayout forKey:@"view4"];
			}
			if (i == 4) {
				view5forLayout = [[TitleAndTextView alloc] initWithClothingModel:(ClothingModel*)[messageArray objectAtIndex:i]];
				[viewDictonary setObject:view5forLayout forKey:@"view5"];
			}
		}
		
		Class class =  NSClassFromString([NSString stringWithFormat:@"Layout%d",layoutNumber]);
		id layoutObject = [[class alloc] init];
		
		if ([layoutObject isKindOfClass:[LayoutViewExtention class]] ) {
			
			layoutToReturn = (LayoutViewExtention*)layoutObject;
			
			[layoutToReturn initalizeViews:viewDictonary];
			[layoutToReturn rotate:self.interfaceOrientation animation:NO];
			[layoutToReturn setFrame:self.view.bounds];
			layoutToReturn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			
			HeaderView* headerView = [[HeaderView alloc] initWithFrame:CGRectMake(0, 0, layoutToReturn.frame.size.width, 50)];
			headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
			[headerView setWallTitleText:[[Session getUser] Name]];
			[headerView setBackgroundColor:[UIColor whiteColor]];
			[headerView rotate:self.interfaceOrientation animation:NO];
			[layoutToReturn setHeaderView:headerView];
			
			FooterView* footerView = [[FooterView alloc] initWithFrame:CGRectMake(0, layoutToReturn.frame.size.height - 20, layoutToReturn.frame.size.width, 20)];
			[footerView setBackgroundColor:[UIColor whiteColor]];
			[footerView setFlipperView:flipper];
			[footerView setViewArray:viewControlerStack];
			
			if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
				[footerView setFrame:CGRectMake(0, 1004 - 20, 768, footerView.frame.size.height)];
			}else {
				[footerView setFrame:CGRectMake(0, 748 - 20, 1024, footerView.frame.size.height)];
			}
			[footerView rotate:self.interfaceOrientation animation:YES];
			
			[layoutToReturn setFooterView:footerView];
		}
	}
	
	return layoutToReturn;
}

-(void)showViewInFullScreen:(UIViewExtention*)viewToShow withModel:(MessageModel*)model{
	if (!isInFullScreenMode) {
		isInFullScreenMode = TRUE;
		
		CGRect bounds = [UIScreen mainScreen].bounds;
		if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
			CGFloat width = bounds.size.width;
			bounds.size.width = bounds.size.height;
			bounds.size.height = width;
		}
		
		
		fullScreenBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
		fullScreenBGView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[fullScreenBGView setBackgroundColor:RGBACOLOR(0,0,0,0.6)];
		fullScreenBGView.alpha = 0;
		[self.view addSubview:fullScreenBGView];
		
		
		viewToShowInFullScreen =  viewToShow;
		viewToShowInFullScreen.originalRect = viewToShowInFullScreen.frame;
		viewToShowInFullScreen.isFullScreen = TRUE;
		FullScreenView* fullView = [[FullScreenView alloc] initWithModel:model];
		fullView.frame = viewToShowInFullScreen.frame;
		fullView.viewToOverLap = viewToShowInFullScreen;
		fullView.fullScreenBG = fullScreenBGView;
		fullScreenView = fullView;
		[self.view addSubview:fullView];
		
		[self.view bringSubviewToFront:fullScreenBGView];	
		[self.view bringSubviewToFront:fullView];
		
		[UIView beginAnimations:@"SHOWFULLSCREEN" context:NULL];
		[UIView setAnimationDuration:0.40];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:nil cache:NO];
		fullScreenBGView.alpha = 1;
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			[fullView setFrame:CGRectMake(10, 50, 768-20, 1004-60)];
		}else {
			[fullView setFrame:CGRectMake(10, 50, 1024-20, 746-60)];
		}
		[fullScreenView rotate:self.interfaceOrientation animation:YES];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];	
		[UIView commitAnimations];
		
	}

	
}

-(void)closeFullScreen {
	if (fullScreenView != nil) {
		fullScreenBGView.alpha=0;
		[fullScreenBGView removeFromSuperview];
		
		fullScreenView.alpha = 0;
		[fullScreenView removeFromSuperview];
		fullScreenView = nil;
		isInFullScreenMode = FALSE;
	}
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	if (fullScreenView != nil) {
		[UIView beginAnimations:@"WILLROTATE" context:NULL];
		[UIView setAnimationDuration:0.50];
		[UIView setAnimationCurve:UIViewAnimationOptionCurveEaseInOut];
		if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			[fullScreenView setFrame:CGRectMake(10, 50, 768-20, 1004-60)];
		}else {
			[fullScreenView setFrame:CGRectMake(10, 50, 1024-20, 748-60)];
		}
		[fullScreenView rotate:toInterfaceOrientation animation:YES];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationEnd:finished:context:)];	
		[UIView commitAnimations];
	}
	
	
	if ([viewControlerStack count] > 0 && [flipper.subviews count] > 0) {
		
		for (UIView* subview in flipper.subviews) {
			if ([subview isKindOfClass:[LayoutViewExtention class]]) {
				LayoutViewExtention* layoutView = (LayoutViewExtention*)subview;
				[layoutView rotate:toInterfaceOrientation animation:YES];
				layoutView.footerView.alpha = 0;
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.10];
				if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
					[layoutView.footerView setFrame:CGRectMake(0, 1004 - 20, 768, layoutView.footerView.frame.size.height)];
				}else {
					[layoutView.footerView setFrame:CGRectMake(0, 748 - 20, 1024, layoutView.footerView.frame.size.height)];
				}
				[layoutView.footerView rotate:toInterfaceOrientation animation:YES];
				[layoutView.headerView rotate:toInterfaceOrientation animation:YES];
				[UIView commitAnimations];
			}
			
		}
		
	}
	
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if ([viewControlerStack count] > 0 && [flipper.subviews count] > 0) {
		for (UIView* subview in flipper.subviews) {
			if ([subview isKindOfClass:[LayoutViewExtention class]]) {
				LayoutViewExtention* layoutView = (LayoutViewExtention*)subview;
				layoutView.footerView.alpha = 1;
			}
		}
	}
}

- (void)animationEnd:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	if ([animationID isEqualToString:@"WILLROTATE"]) {
		if (fullScreenView != nil) {
			[fullScreenView setBackgroundColor:RGBACOLOR(0,0,0,0.6)];
		}		
	}else if ([animationID isEqualToString:@"FOOTER"]) {
		if (context) {
			((__bridge UIView*)context).alpha = 1;
		}
	}else if ([animationID isEqualToString:@"SHOWFULLSCREEN"]) {
		[fullScreenView showFields];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (flipper) {
		return !flipper.animating;
	}
	
	return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}


-(void) generateViews:(NSArray *)currentMesageArray {
	
	int remainingMessageCount = 0;
	int totalMessageCount = [currentMesageArray count];
	int numOfGroup = totalMessageCount /5;
	
	remainingMessageCount = totalMessageCount;
	
	for (int i=1; i<=numOfGroup; i++) {
		remainingMessageCount = totalMessageCount - (i * 5);
		int randomNumber = [self getRandomNumber:5 to:8];
		
		[viewControlerStack addObject:[NSString stringWithFormat:@"%d",randomNumber]];
	}
	
	if (remainingMessageCount > 0) {
		numOfGroup += 1;
		[viewControlerStack addObject:[NSString stringWithFormat:@"%d",remainingMessageCount]];
	}
	
	flipper.numberOfPages = [viewControlerStack count];	
	
	if ([viewControlerStack count] > 0 && flipper.currentView) {
		if ([flipper.currentView isKindOfClass:[LayoutViewExtention class]]) {
			LayoutViewExtention* layoutView = (LayoutViewExtention*)flipper.currentView;
			[layoutView.footerView performSelectorInBackground:@selector(updateBarButtons:) withObject:[NSString stringWithFormat:@"%d",numOfGroup]];
		}
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	//[gestureRecognizer release];
}


@end
