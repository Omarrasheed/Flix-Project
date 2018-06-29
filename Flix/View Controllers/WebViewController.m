//
//  WebViewController.m
//  Flix
//
//  Created by Omar Rasheed on 6/28/18.
//  Copyright © 2018 Omar Rasheed. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (nonatomic, strong) NSArray *trailers;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSString *urlString = [@"https://api.themoviedb.org/3/movie/" stringByAppendingString:self.movieID];
//    NSString *finalString = [urlString stringByAppendingString: (@"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US")];
//
//    NSURL *url = [NSURL URLWithString:finalString];
    
    
    [self fetchTrailers];
    
    
    
    
//    // Place the URL in a URL Request.
//    NSURLRequest *request = [NSURLRequest requestWithURL:url
//                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                         timeoutInterval:10.0];
//    // Load Request into WebView.
//    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchTrailers {
    NSString *urlString = [@"https://api.themoviedb.org/3/movie/" stringByAppendingString:self.movieID];
    NSString *finalString = [urlString stringByAppendingString: (@"/videos?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US")];
    
    NSURL *url = [NSURL URLWithString:finalString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
//                                                                           message:@"Could not retrieve movies from server"
//                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
//            // create a cancel action
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
//                                                                   style:UIAlertActionStyleCancel
//                                                                 handler:^(UIAlertAction * _Nonnull action) {
//                                                                     // handle cancel response here. Doing nothing will dismiss the view.
//                                                                 }];
//            // add the cancel action to the alertController
//            [alert addAction:cancelAction];
//
//            // create an OK action
//            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
//                                                               style:UIAlertActionStyleDefault
//                                                             handler:^(UIAlertAction * _Nonnull action) {
//                                                                 [self.refreshControl endRefreshing];
//                                                                 // handle response here.
//                                                             }];
//            // add the OK action to the alert controller
//            [alert addAction:okAction];
//
//            [self presentViewController:alert animated:YES completion:^{
//                // optional code for what happens after the alert controller has finished presenting
//            }];
//            [self.movies removeAllObjects];
//            [self.moviesTableView reloadData];
//
//            [self.loadingIndicator stopAnimating];
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.trailers = dataDictionary[@"results"];
            
            NSString *key = [self.trailers firstObject][@"key"];
            
            NSString *firstURL = @"https://www.youtube.com/watch?v=";
            
            NSString *finalURLString = [firstURL stringByAppendingString:key];
            
            NSURL *finalURL = [NSURL URLWithString:finalURLString];
            
            // Place the URL in a URL Request.
            NSURLRequest *request = [NSURLRequest requestWithURL:finalURL
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:10.0];
            // Load Request into WebView.
            [self.webView loadRequest:request];
        }
    }];
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
