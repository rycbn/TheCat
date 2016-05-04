//
//  TheCatTableViewCell.h
//  TheCat
//
//  Created by Roger Yong on 03/05/2016.
//  Copyright © 2016 rycbn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TheCatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *catImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
