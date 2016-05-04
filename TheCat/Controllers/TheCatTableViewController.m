//
//  TheCatTableViewController.m
//  TheCat
//
//  Created by Roger Yong on 03/05/2016.
//  Copyright © 2016 rycbn. All rights reserved.
//

#import "TheCatTableViewController.h"
#import "TheCatDetailViewController.h"
#import "TheCatTableViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "NSDictionary+TheCatPackage.h"
#import "Utilities.h"

@interface TheCatTableViewController () <NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableDictionary *currentDictionary;
@property (strong, nonatomic) NSMutableDictionary *xmlTheCat;
@property (strong, nonatomic) NSString *elementName;
@property (strong, nonatomic) NSMutableString *outstring;
@property (strong, nonatomic) NSDictionary *theCat;
@property (strong, nonatomic) NSMutableArray *tableRowHeights;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

static NSString *CellIdentifier = @"TheCatCell";
static NSString *theCatApiUrl = @"http://thecatapi.com/api/images/get?format=xml&results_per_page=20";

@implementation TheCatTableViewController
@synthesize refreshControl = _refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Cats List";
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_refreshControl beginRefreshing];
        [_refreshControl endRefreshing];
    });
    
    [self loadDataRefresh:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableRowHeights[indexPath.row] integerValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.theCat.upcomingCat.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TheCatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *theCat = nil;
    theCat = self.theCat.upcomingCat[indexPath.row];
    
    NSURL *url = [NSURL URLWithString:theCat.imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak TheCatTableViewCell *weakCell = cell;
    __weak typeof(self) weakSelf = self;

    cell.indicator.hidden = false;
    [cell.indicator startAnimating];

    [cell.catImageView setImageWithURLRequest:request
                             placeholderImage:[UIImage new]
                                      success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                                          
                                          weakCell.catImageView.image = image;
                                          
                                          NSInteger oldHeight = [weakSelf.tableRowHeights[indexPath.row] integerValue];
                                          NSInteger newHeight = (int)image.size.height;
                                          
                                          if (image.size.width > CGRectGetWidth(weakCell.imageView.bounds)) {
                                              CGFloat ratio = image.size.height / image.size.width;
                                              newHeight = CGRectGetWidth(self.view.bounds) * ratio;
                                          }
                                          if (oldHeight != newHeight) {
                                              weakSelf.tableRowHeights[indexPath.row] = @(newHeight);
                                              [weakSelf.tableView beginUpdates];
                                              //[weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                              [weakSelf.tableView endUpdates];
                                          }
                                          [weakCell setNeedsLayout];
                                          [weakCell setNeedsDisplay];
                                          [weakCell setNeedsUpdateConstraints];

                                          [cell.indicator stopAnimating];
                                          cell.indicator.hidden = true;

                                      } failure:nil];
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TheCatDetailSegue"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        TheCatDetailViewController *catVC = (TheCatDetailViewController *)segue.destinationViewController;
        catVC.theCat = self.theCat.upcomingCat[indexPath.row];
    }
}

#pragma mark - Internal Action
- (void)refreshData:(UIRefreshControl *)refreshControl {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadDataRefresh:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = [countryCode isEqualToString:@"US"] ? @"MM/dd/yyyy, HH:mm" : @"dd/MM/yyyy, HH:mm";
            NSString *lastUpdate = [NSString stringWithFormat:@"Last updated: %@", [formatter stringFromDate:[NSDate date]]];
            refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
        });
    });
}

- (void)loadDataRefresh:(BOOL)isRefresh {
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        BOOL isNetworkReachable = false;
        BOOL hasCellularCoverage = false;
        if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
            isNetworkReachable = true;
        }
        if ([Utilities hasCellularCoverage]) {
            hasCellularCoverage = true;
        }
        if (isNetworkReachable || hasCellularCoverage) {
            NSURL *url = [NSURL URLWithString:theCatApiUrl];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
                [XMLParser setShouldProcessNamespaces:YES];
                XMLParser.delegate = self;
                [XMLParser parse];
                if (isRefresh) {
                    [_refreshControl endRefreshing];
                }
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                [Utilities displayAlertWithTitle:@"Sorry" message:@"Error Retrieving The Cat API" viewController:self];
                if (isRefresh) {
                    [_refreshControl endRefreshing];
                }
            }];
        } else {
            [Utilities displayAlertWithTitle:@"Network Error" message:@"Please check your Internet connection and try again." viewController:self];
            if (isRefresh) {
                [_refreshControl endRefreshing];
            }
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.xmlTheCat = [NSMutableDictionary dictionary];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.elementName = qName;
    if ([qName isEqualToString:@"image"]) {
        self.currentDictionary = [NSMutableDictionary dictionary];
    }
    self.outstring = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self.elementName)
        return;
    [self.outstring appendFormat:@"%@", string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([qName isEqualToString:@"image"]) {
        NSMutableArray *array = self.xmlTheCat[@"image"] ?: [NSMutableArray array];
        [array addObject:self.currentDictionary];
        self.xmlTheCat[@"image"] = array;
        self.currentDictionary = nil;
    }
    else if (qName) {
        self.currentDictionary[qName] = self.outstring;
    }
    self.elementName = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.theCat = @{@"images": self.xmlTheCat};
    [self setDefaultRowHeights];
    [self.tableView reloadData];
}

- (void)setDefaultRowHeights {
    self.tableRowHeights = [NSMutableArray arrayWithCapacity:self.theCat.upcomingCat.count];
    for (int i = 0; i < self.theCat.upcomingCat.count; i++) {
        self.tableRowHeights[i] = @(self.tableView.rowHeight);
    }
}

@end
