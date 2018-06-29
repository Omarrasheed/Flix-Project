//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Omar Rasheed on 6/28/18.
//  Copyright © 2018 Omar Rasheed. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailViewController.h"
#import "HeaderCollectionReusableView.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *searchedMovies;
@property (strong, nonatomic) NSArray *groups;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *filteredData;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *collectionRefreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property NSInteger *sectionCount;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.sectionCount = (NSInteger *)2;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = self.collectionView.frame.size.width / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.searchBar.delegate = self;
    
    [self.activityIndicator startAnimating];
    
    self.collectionRefreshControl = [[UIRefreshControl alloc] init];
    [self.collectionRefreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    
    [self.collectionView insertSubview:self.collectionRefreshControl atIndex:0];
    
    [self fetchMovies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            self.movies = dataDictionary[@"results"];
            self.filteredData = self.movies;
            [self.activityIndicator stopAnimating];
            [self.collectionView reloadData];
        }
        [self.collectionRefreshControl endRefreshing];
    }];
    [task resume];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.filteredData[indexPath.item];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *imageURLString = movie[@"poster_path"];
    if (![movie[@"poster_path"] isEqual:[NSNull null]]) {
        NSString *fullURLString = [baseURLString stringByAppendingString:imageURLString];
        NSURL *imageURL = [NSURL URLWithString:fullURLString];
        cell.posterView.image = nil;
        [cell.posterView setImageWithURL:imageURL];
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.filteredData.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionCount;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        self.sectionCount = (NSInteger *)1;
        NSString *beginningOfAPI = [NSString stringWithFormat:(@"https://api.themoviedb.org/3/search/movie?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&query=")];
        
        NSString *realSearchText = [[searchText stringByReplacingOccurrencesOfString:@" " withString:([@"%" stringByAppendingString:[NSString stringWithFormat:(@"20")]])] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:([@"%" stringByAppendingString:[NSString stringWithFormat:(@"20")]])] withString:[NSString stringWithFormat:@""]];
        
        NSString *middleOfAPI = [beginningOfAPI stringByAppendingString:(realSearchText)];
        
        NSString *finalAPIString = [middleOfAPI stringByAppendingString:[NSString stringWithFormat:@"&language=en-US&page=1"]];
        
        NSURL *searchAPIString =[NSURL URLWithString:finalAPIString];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:searchAPIString cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            else {
                NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                self.searchedMovies = dataDictionary[@"results"];
                
                NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
                    return [evaluatedObject[@"title"] containsString:searchText];
                }];
                self.filteredData = [self.searchedMovies filteredArrayUsingPredicate:predicate];
                
                NSLog(@"%@", self.filteredData);
                
                [self.collectionView reloadData];
            }
        }];
        [task resume];
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredData = [self.searchedMovies filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@", self.filteredData);
        
    }
    else {
        self.sectionCount = (NSInteger *)2;
        self.filteredData = self.movies;
        [self.collectionView reloadData];
    }
    
    
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableview = nil;
    self.groups = @[[NSString stringWithFormat:@"Most Popular"], [NSString stringWithFormat:@"Least Popular"]];
    
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        
        NSString *title = [[NSString alloc]initWithFormat: @"%@", self.groups[indexPath.section]];
        headerView.sectionLabel.text = title;
        
        reusableview = headerView;
    }
    
    return reusableview;
}

@end
