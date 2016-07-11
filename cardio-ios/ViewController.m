//
//  ViewController.m
//  cardio-ios
//
//  Created by Sylvain Reucherand on 11/07/16.
//  Copyright © 2016 Sylvain Reucherand. All rights reserved.
//

#import "ViewController.h"
#import "CardView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *previewView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scan:(id)sender {
    CardView *cardView = [[CardView alloc] initWithFrame:self.previewView.frame];
    cardView.delegate = self;
    cardView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:cardView];
}

#pragma mark - CardViewDelegate methods

- (void)didScanCard:(CGFloat)info {
    NSLog(@"Coucou");
}

@end
