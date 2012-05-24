//
//  AFKPageFlipper.m
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-12.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//

#import "AFKPageFlipper.h"
#import "ChapterEPub.h"


#pragma mark -
#pragma mark UIView helpers


@interface UIView(Extended) 

- (UIImage *) imageByRenderingView;

@end


@implementation UIView(Extended)


- (UIImage *) imageByRenderingView {
    CGFloat oldAlpha = self.alpha;
    self.alpha = 1;
    UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    self.alpha = oldAlpha;
	return resultingImage;
}

@end


#pragma mark -
#pragma mark Private interface


@interface AFKPageFlipper()

@property (nonatomic,assign) UIView *currentView;
@property (nonatomic,assign) UIView *nextView;

@end


@implementation AFKPageFlipper

@synthesize tapRecognizer = _tapRecognizer;
@synthesize panRecognizer = _panRecognizer;
//BookReader
@synthesize pinchRecognizer = _pinchRecognizer;
@synthesize delegate;

@synthesize pageMode;
@synthesize chapters;


#pragma mark -
#pragma mark Flip functionality


- (void) initFlip {
	
	// Create screenshots of view
	
	UIImage *currentImage = [self.currentView imageByRenderingView];
	UIImage *newImage = [self.nextView imageByRenderingView];
    NSLog(@"done get new image for next view");
	
	// Hide existing views
	
	self.currentView.alpha = 0;
	self.nextView.alpha = 0;
	
	// Create representational layers
	
	CGRect rect = self.bounds;
	rect.size.width /= 2;
	
	backgroundAnimationLayer = [CALayer layer];
	backgroundAnimationLayer.frame = self.bounds;
	backgroundAnimationLayer.zPosition = -300000;
	
	CALayer *leftLayer = [CALayer layer];
	leftLayer.frame = rect;
	leftLayer.masksToBounds = YES;
	leftLayer.contentsGravity = kCAGravityLeft;
	
	[backgroundAnimationLayer addSublayer:leftLayer];
	
	rect.origin.x = rect.size.width;
	
	CALayer *rightLayer = [CALayer layer];
	rightLayer.frame = rect;
	rightLayer.masksToBounds = YES;
	rightLayer.contentsGravity = kCAGravityRight;
	
	[backgroundAnimationLayer addSublayer:rightLayer];
	
	if (flipDirection == AFKPageFlipperDirectionRight) {
		leftLayer.contents = (id) [newImage CGImage];
		rightLayer.contents = (id) [currentImage CGImage];
	} else {
		leftLayer.contents = (id) [currentImage CGImage];
		rightLayer.contents = (id) [newImage CGImage];
	}

	[self.layer addSublayer:backgroundAnimationLayer];
	
	rect.origin.x = 0;
	
	flipAnimationLayer = [CATransformLayer layer];
	flipAnimationLayer.anchorPoint = CGPointMake(1.0, 0.5);
	flipAnimationLayer.frame = rect;
	
	[self.layer addSublayer:flipAnimationLayer];
	
	CALayer *backLayer = [CALayer layer];
	backLayer.frame = flipAnimationLayer.bounds;
	backLayer.doubleSided = NO;
	backLayer.masksToBounds = YES;
	
	[flipAnimationLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	frontLayer.frame = flipAnimationLayer.bounds;
	frontLayer.doubleSided = NO;
	frontLayer.masksToBounds = YES;
	frontLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1.0, 0);
	
	[flipAnimationLayer addSublayer:frontLayer];
	
	if (flipDirection == AFKPageFlipperDirectionRight) {
		backLayer.contents = (id) [currentImage CGImage];
		backLayer.contentsGravity = kCAGravityLeft;
		
		frontLayer.contents = (id) [newImage CGImage];
		frontLayer.contentsGravity = kCAGravityRight;
		
		CATransform3D transform = CATransform3DMakeRotation(0.0, 0.0, 1.0, 0.0);
		transform.m34 = 1.0f / 2500.0f;
		
		flipAnimationLayer.transform = transform;
		
		currentAngle = startFlipAngle = 0;
		endFlipAngle = -M_PI;
	} else {
		backLayer.contentsGravity = kCAGravityLeft;
		backLayer.contents = (id) [newImage CGImage];
		
		frontLayer.contents = (id) [currentImage CGImage];
		frontLayer.contentsGravity = kCAGravityRight;
		
		CATransform3D transform = CATransform3DMakeRotation(-M_PI / 1.1, 0.0, 1.0, 0.0);
		transform.m34 = 1.0f / 2500.0f;
		
		flipAnimationLayer.transform = transform;
		
		currentAngle = startFlipAngle = -M_PI;
		endFlipAngle = 0;
	}
}


- (void) cleanupFlip {
	[backgroundAnimationLayer removeFromSuperlayer];
	[flipAnimationLayer removeFromSuperlayer];
	
	backgroundAnimationLayer = Nil;
	flipAnimationLayer = Nil;
	
	animating = NO;
	
	if (setNextViewOnCompletion) {
		[self.currentView removeFromSuperview];
		self.currentView = self.nextView;
		self.nextView = Nil;
	} else {
		[self.nextView removeFromSuperview];
		self.nextView = Nil;
	}

	self.currentView.alpha = 1;
    [self setUserInteractionEnabled:YES];
}


- (void) setFlipProgress:(float) progress setDelegate:(BOOL) setDelegate animate:(BOOL) animate {
    if (animate) {
        animating = YES;
    }
    
	float newAngle = startFlipAngle + progress * (endFlipAngle - startFlipAngle);
	
	float duration = animate ? 0.5 * fabs((newAngle - currentAngle) / (endFlipAngle - startFlipAngle)) : 0;
	
	currentAngle = newAngle;
	
	CATransform3D endTransform = CATransform3DIdentity;
	endTransform.m34 = 1.0f / 2500.0f;
	endTransform = CATransform3DRotate(endTransform, newAngle, 0.0, 1.0, 0.0);	
	
	[flipAnimationLayer removeAllAnimations];
    [self setUserInteractionEnabled:NO];
							
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	
	flipAnimationLayer.transform = endTransform;
	
	[CATransaction commit];
	
	if (setDelegate) {
		[self performSelector:@selector(cleanupFlip) withObject:Nil afterDelay:duration];
	}
    
    if (progress == 1.0f) {
        if ([self delegate] != nil) {
            if ([[self delegate] respondsToSelector:@selector(pageFlipper:didFlipToPage:)]) {
                [[self delegate] pageFlipper:self didFlipToPage:[self currentPage]];
            }
        }	
    }
}


- (void) flipPage {
	[self setFlipProgress:1.0 setDelegate:YES animate:YES];
}


#pragma mark -
#pragma mark Animation management


- (void)animationDidStop:(NSString *) animationID finished:(NSNumber *) finished context:(void *) context {
	[self cleanupFlip];
}


#pragma mark -
#pragma mark Properties

@synthesize currentView;


- (void) setCurrentView:(UIView *) value {
	if (currentView) {
		[currentView release];
	}
	
	currentView = [value retain];
}


@synthesize nextView;


- (void) setNextView:(UIView *) value {
	if (nextView) {
		[nextView release];
	}
	
	nextView = [value retain];
}


@synthesize currentPage;
//For BookReader
@synthesize currentPDFPage;

@synthesize currentEPubPage;
@synthesize currentEPubChapter;


- (BOOL) doSetCurrentPage:(NSInteger) value {
    
    /*
	if (value == currentPage) {
		return FALSE;
	}
    */
	
    flipDirection = value < currentPage ? AFKPageFlipperDirectionRight : AFKPageFlipperDirectionLeft;
	
	currentPage = value;
    //currentPDFPage = value;
	
	self.nextView = [self.dataSource viewForPage:value inFlipper:self];
	[self addSubview:self.nextView];
	
	return TRUE;
}	

- (void) setCurrentPage:(NSInteger) value {
	if (![self doSetCurrentPage:value]) {
		return;
	}
	
	setNextViewOnCompletion = YES;
	animating = YES;
	
	self.nextView.alpha = 0;
	
	[UIView beginAnimations:@"" context:Nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	self.nextView.alpha = 1;
	
	[UIView commitAnimations];
} 


- (void) setCurrentPage:(NSInteger) value animated:(BOOL) animated {
	if (![self doSetCurrentPage:value]) {
		return;
	}
	
	setNextViewOnCompletion = YES;
	animating = YES;
	
	if (animated) {
		[self initFlip];
		[self performSelector:@selector(flipPage) withObject:Nil afterDelay:0.001];
	} else {
		[self animationDidStop:Nil finished:[NSNumber numberWithBool:NO] context:Nil];
	}
}


@synthesize dataSource;


- (void) setDataSource:(NSObject <AFKPageFlipperDataSource>*) value {
	if (dataSource) {
		[dataSource release];
	}
	
	dataSource = [value retain];
	numberOfPages = [dataSource numberOfPagesForPageFlipper:self];
    currentPage = 0;
    //For BookReader
    currentPDFPage = 1;
    currentEPubPage = 1;
    currentEPubChapter = 1;
	
    self.currentPage = 1;
    //For BookReader
    self.currentPDFPage = 1;
}


@synthesize disabled;


- (void) setDisabled:(BOOL) value {
	disabled = value;
	
	self.userInteractionEnabled = !value;
	
	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
		recognizer.enabled = !value;
	}
}


#pragma mark -
#pragma mark Touch management


- (void) tapped:(UITapGestureRecognizer *) recognizer {
	if (animating || self.disabled) {
		return;
	}
	
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		NSInteger newPage;
		
		if ([recognizer locationInView:self].x < (self.bounds.size.width - self.bounds.origin.x) / 2) {
			newPage = MAX(1, self.currentPage - 1);
		} else {
			newPage = MIN(self.currentPage + 1, numberOfPages);
		}
		
		[self setCurrentPage:newPage animated:YES];
	}
}


- (void) panned:(UIPanGestureRecognizer *) recognizer {
    NSLog(@"panned");
    if (animating) {
        return;
    }
    
	static BOOL hasFailed;
	static BOOL initialized;
	
	static NSInteger oldPage;
    //For BookReader
    static NSInteger oldPDFPage;
    
    //static NSInteger oldEPubPage;
    //static NSInteger oldEPubChapter;

	float translation = [recognizer translationInView:self].x;
	
	float progress = translation / self.bounds.size.width;
	
	if (flipDirection == AFKPageFlipperDirectionLeft) {
		progress = MIN(progress, 0);
	} else {
		progress = MAX(progress, 0);
	}
	
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			hasFailed = FALSE;
			initialized = FALSE;
			animating = NO;
			setNextViewOnCompletion = NO;
			break;
			
			
		case UIGestureRecognizerStateChanged:
			
			if (hasFailed) {
				return;
			}
			
			if (!initialized) {
				oldPage = self.currentPage;
                //For BookReader
                oldPDFPage = self.currentPDFPage;
				
				if (translation > 0) {
					if (self.currentPage > 1) {
                        NSLog(@"back page");
                        //For BookReader
                        //Landscape
                        if (self.bounds.size.width > self.bounds.size.height) {
                            self.currentPDFPage = MAX(1, self.currentPDFPage - 2);
                            //self.currentPDFPage -= 2;
                        }
                        //Portrait
                        else {
                            //if (self.pageMode == 0) {
                                self.currentPDFPage = MAX(1, self.currentPDFPage - 1);
                            //}
                            /*else if (self.pageMode == 1) {
                                if (self.currentEPubPage == 1) {
                                    if (self.currentPDFPage > 1) {
                                        self.currentPDFPage--;
                                        self.currentEPubPage = [[self.chapters objectAtIndex:self.currentPDFPage - 1] numPages];
                                    }
                                }
                                else {
                                    self.currentEPubPage--;
                                }
                            }*/
                            //self.currentPDFPage -= 1;
                        }
                        
						[self doSetCurrentPage:self.currentPDFPage];
					} else {
						hasFailed = TRUE;
						return;
					}
				} else {
					if (self.currentPage < numberOfPages) {
                        NSLog(@"next page");
                        //For BookReader
                        //Landscape
                        if (self.bounds.size.width > self.bounds.size.height) {
                            self.currentPDFPage = MIN(self.currentPDFPage + 2, numberOfPages);
                            //self.currentPDFPage += 2;
                        }
                        //Portrait
                        else {
                            //self.currentPDFPage += 1;
                            //if (self.pageMode == 0) {
                                self.currentPDFPage = MIN(self.currentPDFPage + 1, numberOfPages);
                            //}
                            /*else if (self.pageMode == 1) {
                                //NSLog(@"Chapter: %i| %i/%i", self.currentPDFPage, self.currentEPubPage, [[self.chapters objectAtIndex:self.currentPDFPage - 1] numPages]);
                                //NSLog(@"next : %i", [[self.chapters objectAtIndex:self.currentPDFPage - 1] idChapter]);
                                if (self.currentEPubPage == [[self.chapters objectAtIndex:self.currentPDFPage - 1] numPages]) {
                                    if (self.currentPDFPage < numberOfPages) {
                                        self.currentPDFPage++;
                                        self.currentEPubPage = 1;
                                    }
                                }
                                else {
                                    self.currentEPubPage++;
                                }
                            }*/
                        }
                        
						[self doSetCurrentPage:self.currentPDFPage];
					} else {
						hasFailed = TRUE;
						return;
					}
				}
				
				hasFailed = NO;
				initialized = TRUE;
				setNextViewOnCompletion = NO;
				
				[self initFlip];
			}
			
			[self setFlipProgress:fabs(progress) setDelegate:NO animate:NO];
			
			break;
			
			
		case UIGestureRecognizerStateFailed:
			[self setFlipProgress:0.0 setDelegate:YES animate:YES];
			currentPage = oldPage;
            
            //For BookReader
            currentPDFPage = oldPDFPage;
            
			break;
			
		case UIGestureRecognizerStateRecognized:
			if (hasFailed) {
				[self setFlipProgress:0.0 setDelegate:YES animate:YES];
				currentPage = oldPage;
                
                //For BookReader
                currentPDFPage = oldPDFPage;
				
				return;
			}
			
			if (fabs((translation + [recognizer velocityInView:self].x / 4) / self.bounds.size.width) > 0.5) {
				setNextViewOnCompletion = YES;
				[self setFlipProgress:1.0 setDelegate:YES animate:YES];
			} else {
				[self setFlipProgress:0.0 setDelegate:YES animate:YES];
				currentPage = oldPage;
                
                //For BookReader
                currentPDFPage = oldPDFPage;
			}

            NSLog(@"CURRENT PAGE = %i", currentPDFPage);
			break;
		default:
			break;
	}
}

- (void) pinched:(UIPinchGestureRecognizer *) recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"pinch begin");
            // Landscape
            NSLog(@"x = %f | y = %f", [recognizer locationInView:self].x, [recognizer locationInView:self].y);
            if (self.bounds.size.width > self.bounds.size.height) {
                if ([recognizer locationInView:self].x < self.bounds.size.width / 2)
                {
                    NSLog(@"left");
                }
                else {
                    NSLog(@"right");
                }
            }
            // Portrait
            else {
                
            }
            
            break;
        
        case UIGestureRecognizerStateEnded:
            NSLog(@"pinch end");
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Frame management


- (void) setFrame:(CGRect) value {
	super.frame = value;
    
    // Landscape
    if (self.bounds.size.width > self.bounds.size.height) {
        numberOfPages = [dataSource numberOfPagesForPageFlipper:self] * 2;
    }
    // Portrait
    else {
        numberOfPages = [dataSource numberOfPagesForPageFlipper:self];
    }
    
	if (self.currentPage > numberOfPages) {
		self.currentPage = numberOfPages;
	}
	
}


#pragma mark -
#pragma mark Initialization and memory management


+ (Class) layerClass {
	return [CATransformLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		//_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        
        //BookReader
        //_pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinched:)];
		
		//[_tapRecognizer requireGestureRecognizerToFail:_panRecognizer];
		
        //[self addGestureRecognizer:_tapRecognizer];
		[self addGestureRecognizer:_panRecognizer];
        //BookReader
        //[self addGestureRecognizer:_pinchRecognizer];
    }
    return self;
}


- (void)dealloc {
	self.dataSource = Nil;
	self.currentView = Nil;
	self.nextView = Nil;
	self.tapRecognizer = Nil;
	self.panRecognizer = Nil;
    //BookReader
    self.pinchRecognizer = Nil;
    [super dealloc];
}


@end
