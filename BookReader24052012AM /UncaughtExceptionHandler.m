//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  Created by Matt Gallagher on 2010/05/25.
//  Copyright 2010 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
#import "Constants.h"
#import "UncaughtExceptionHandler.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <unistd.h>

#import "FlurryAnalytics.h"
//#import "UserUtility.h"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
	 void* callstack[128];
	 int frames = backtrace(callstack, 128);
	 char **strs = backtrace_symbols(callstack, frames);
	 
	 int i;
	 NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	 for (
	 	i = UncaughtExceptionHandlerSkipAddressCount;
	 	i < UncaughtExceptionHandlerSkipAddressCount +
			UncaughtExceptionHandlerReportAddressCount;
		i++)
	 {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
	 }
	 free(strs);
	 
	 return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
	if (anIndex == 0)
	{
		dismissed = YES;
	}
}

- (void)validateAndSaveCriticalApplicationData
{
	NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:YES forKey:@"CrashException"];
//	[userDefaults setObject:nil forKey:keySymbolsForQuotes];
	[userDefaults setObject:nil forKey:kCurrentSymbol];
	//[userDefaults setObject:nil forKey:kChartObjects];
	DBLog(@"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
	DBLog(@"CCCCCCCCCCCCExceptionCCCCCCCCCCCCCCCCCCCCCC");
	DBLog(@"CCCCCCCCCCCCExceptionCCCCCCCCCCCCCCCCCCCCCC");
	DBLog(@"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
	
	//[NSUserDefaults resetStandardUserDefaults];
	[userDefaults synchronize];
	
}

- (void)handleException:(NSException *)exception
{
    NSString *faMessage = @"";
//    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
//    faMessage = [faMessage stringByAppendingFormat:@"Symbol:%@", [[userDefaults objectForKey:(NSString *)kCurrentSymbol] description]];
//    faMessage = [faMessage stringByAppendingFormat:@" Timescale:%@", [[userDefaults objectForKey:(NSString *)kCurrentTimeScale] description]];
//    faMessage = [faMessage stringByAppendingFormat:@" Session:%@", [userDefaults objectForKey:@"keySession"]];
//    faMessage = [faMessage stringByAppendingFormat:@" UserType:%@", (([UserUtility isUserLogin]) ? @"Barchart" : @"Non-Ads")];
//    faMessage = [faMessage stringByAppendingFormat:@" Logarit:%@", (([userDefaults boolForKey:@"keyLogarithmicScale"]) ? @"YES" : @"NO")];
//    faMessage = [faMessage stringByAppendingFormat:@" ChartType:%@", [[userDefaults objectForKey:@"keyChartType"] description]]; 
//    faMessage = [faMessage stringByAppendingFormat:@"%@",[]];
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
    faMessage = [faMessage stringByAppendingFormat:@" DeviceInfo:%@-%@-%@-%@-%@-%@", appName, appVersion, deviceName, deviceModel, deviceSystemVersion];
    
	[FlurryAnalytics logError:[exception name] 
                      message:faMessage //[exception reason] 
                    exception:exception];
	
	[self validateAndSaveCriticalApplicationData];
	
	//CPAD-75: use debug as console not a dialog
#ifdef DEBUGGING
	UIAlertView *alert =
		[[[UIAlertView alloc]
			initWithTitle:NSLocalizedString(@"Unhandled exception", nil)
			message:[NSString stringWithFormat:NSLocalizedString(
				//@"You can try to continue but the application may be unstable.\n\n"
				@"Debug details follow:\n%@\n%@", nil),
				[exception reason],
				[[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]]
			delegate:self
			cancelButtonTitle:NSLocalizedString(@"Quit", nil)
			otherButtonTitles:nil, nil]
		autorelease];
	[alert show];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Debug details follow:\n%@\n%@", nil),
						 [exception reason],
						 [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    DBLog(@"%@", message);
#else
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Debug details follow:\n%@\n%@", nil),
						 [exception reason],
						 [[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
	NSLog(@"%@", message);
#endif
    
    //18012012phien - 
    //reason: This exception may be caused by upgrading application.
//    if ([[exception reason] rangeOfString:@"11"].length > 0) {
//        NSLog(@"PDEBUG: Signal 11");
//        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"System data corrupted!" message:@"Please remove application and install it again. Or you contact support@ichartist.com for detail." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease];
//        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
//    }
	
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
	
	while (!dismissed)
	{
		for (NSString *mode in (NSArray *)allModes)
		{
			CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
		}
#ifdef DEBUGGING
#else
		dismissed = YES;
#endif
	}
	
	CFRelease(allModes);

	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
	
	if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
	{
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
	}
	else
	{
		[exception raise];
	}
}

@end

void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	NSMutableDictionary *userInfo =
		[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[[UncaughtExceptionHandler alloc] init] autorelease]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:[exception name]
				reason:[exception reason]
				userInfo:userInfo]
		waitUntilDone:YES];
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
	if (exceptionCount > UncaughtExceptionMaximum)
	{
		return;
	}
	
	NSMutableDictionary *userInfo =
		[NSMutableDictionary
			dictionaryWithObject:[NSNumber numberWithInt:signal]
			forKey:UncaughtExceptionHandlerSignalKey];

	NSArray *callStack = [UncaughtExceptionHandler backtrace];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKey];
	
	[[[[UncaughtExceptionHandler alloc] init] autorelease]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
				reason:
					[NSString stringWithFormat:
						NSLocalizedString(@"Signal %d was raised.", nil),
						signal]
				userInfo:
					[NSDictionary
						dictionaryWithObject:[NSNumber numberWithInt:signal]
						forKey:UncaughtExceptionHandlerSignalKey]]
		waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler()
{
	NSSetUncaughtExceptionHandler(&HandleException);
	signal(SIGABRT, SignalHandler);
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGPIPE, SignalHandler);
}

