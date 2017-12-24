//
//  NostalgiaCamera.h
//  NostalgiaScanner
//
//  Created by Dwayne Forde on 2017-12-23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NostalgiaCameraDelegate <NSObject>

- (void)matchedItem;

@end


@interface NostalgiaCamera : NSObject

-(id) initWithController: (UIViewController<NostalgiaCameraDelegate>*)c andImageView: (UIImageView*)iv;
-(void)start;
-(void)stop;

@end
