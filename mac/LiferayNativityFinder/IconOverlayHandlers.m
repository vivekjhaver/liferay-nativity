/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

#import <objc/runtime.h>
#import "ContentManager.h"
#import "IconCache.h"
#import "IconOverlayHandlers.h"
#import "Finder/Finder.h"

@implementation NSObject (IconOverlayHandlers)

- (void)IconOverlayHandlers_drawIconWithFrame:(struct CGRect)arg1
{
	[self IconOverlayHandlers_drawIconWithFrame:arg1];

	NSURL* url = [[NSClassFromString(@"FINode") nodeFromNodeRef:[(TIconAndTextCell*)self node]->fNodeRef] previewItemURL];

	NSNumber* imageIndex = [[ContentManager sharedInstance] iconByPath:[url path]];

	if ([imageIndex intValue] > 0)
	{
		NSImage* image = [[IconCache sharedInstance] getIcon:imageIndex];

		if (image != nil)
		{
			struct CGRect arg2 = [(TIconViewCell*)self imageRectForBounds:arg1];

			[image drawInRect:NSMakeRect(arg2.origin.x, arg2.origin.y, arg2.size.width, arg2.size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:TRUE hints:nil];
		}
	}
}

- (void)IconOverlayHandlers_IKImageBrowserCell_drawImage:(id)arg1
{
	IKImageWrapper*imageWrapper = [self IconOverlayHandlers_imageWrapper:arg1];

	[self IconOverlayHandlers_IKImageBrowserCell_drawImage:imageWrapper];
}

- (void)IconOverlayHandlers_IKFinderReflectiveIconCell_drawImage:(id)arg1
{
	IKImageWrapper*imageWrapper = [self IconOverlayHandlers_imageWrapper:arg1];

	[self IconOverlayHandlers_IKFinderReflectiveIconCell_drawImage:imageWrapper];
}

- (IKImageWrapper*)IconOverlayHandlers_imageWrapper:(id)arg1
{
	TIconViewCell* realSelf = (TIconViewCell*)self;
	FINode* node = (FINode*)[realSelf representedItem];

	NSURL* url = [node previewItemURL];

	NSNumber* imageIndex = [[ContentManager sharedInstance] iconByPath:[url path]];

	if ([imageIndex intValue] > 0)
	{
		NSImage* icon = [arg1 _nsImage];

		[icon lockFocus];

		CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];

		NSImage* iconimage = [[IconCache sharedInstance] getIcon:[NSNumber numberWithInt:[imageIndex intValue]]];

		if (iconimage != nil)
		{
			CGImageSourceRef source;
			NSData* data = [iconimage TIFFRepresentation];

			source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
			CGImageRef maskRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
			CGContextDrawImage(myContext, CGRectMake(0, 0, [icon size].width, [icon size].height), maskRef);
			CFRelease(source);
			CFRelease(maskRef);
		}

		[icon unlockFocus];

		return [[[IKImageWrapper alloc] initWithNSImage:icon] autorelease];
	}
	else
	{
		return arg1;
	}
}

- (void)IconOverlayHandlers_drawRect:(struct CGRect)arg1
{
	[self IconOverlayHandlers_drawRect:arg1];

	NSView* supersuperview = [[(NSView*)self superview] superview];

	if ([supersuperview isKindOfClass:(id)objc_getClass("TListRowView")])
	{
		TListRowView *listRowView = (TListRowView*) supersuperview;
		FINode *fiNode;

		object_getInstanceVariable(listRowView, "_node", (void**)&fiNode);

		NSURL *url;

		if ([fiNode respondsToSelector:@selector(previewItemURL)])
		{
			url = [fiNode previewItemURL];
		}
		else {
			return;
		}

		NSNumber* imageIndex = [[ContentManager sharedInstance] iconByPath:[url path]];

		if ([imageIndex intValue] > 0)
		{
			NSImage* image = [[IconCache sharedInstance] getIcon:imageIndex];

			if (image != nil)
			{
				[image drawInRect:NSMakeRect(arg1.origin.x, arg1.origin.y, arg1.size.width, arg1.size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:TRUE hints:nil];
			}
		}

	}
}

@end