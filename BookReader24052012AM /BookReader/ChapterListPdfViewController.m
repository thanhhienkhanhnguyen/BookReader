//
//  ChapterListPdfViewController.m
//  BookReader
//
//  Created by mac on 4/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ChapterListPdfViewController.h"

@implementation ChapterListPdfViewController

@synthesize pdfViewController = _pdfViewController;
@synthesize txtPage = _txtPage;
@synthesize txtTotalPages = _txtTotalPages;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - button GO
/*
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"string = %@", string);
    if ([string isEqualToString:@""]) {
        NSLog(@"is deleted");
        return NO;
    }
    else {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0);
    }
    
}
*/
- (IBAction)goBtnIsPressed:(id)sender
{
    NSLog(@"go button is pressed");
    //NSLog(@"num page = %i", self.pdfViewController.numberOfPages);
    self.pdfViewController.isGoToPage = YES;
    
    NSInteger idGoto = [self.txtPage.text intValue];
    NSLog(@"idGoto = %i", idGoto);
    
    if (idGoto > 0 && idGoto <= [self.pdfViewController getNumberOfPDFPage]) {
        self.pdfViewController.currentIdPage = idGoto;
    }
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"will appear");
    
    [super viewWillAppear:animated];
    
    [self.txtPage setText:[NSString stringWithFormat:@"%i", self.pdfViewController.currentIdPage]];
    [self.txtTotalPages setText:[NSString stringWithFormat:@"%i", [self.pdfViewController getNumberOfPDFPage]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
