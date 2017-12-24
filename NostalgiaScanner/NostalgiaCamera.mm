//
//  NostalgiaCamera.m
//  NostalgiaScanner
//
//  Created by Dwayne Forde on 2017-12-23.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>
#include "NostalgiaCamera.h"

using namespace cv;
using namespace std;

@interface NostalgiaCamera () <CvVideoCameraDelegate>
@end

@implementation NostalgiaCamera
{
    UIViewController<NostalgiaCameraDelegate> * delegate;
    UIImageView * imageView;
    CvVideoCamera * videoCamera;
    cv::Mat tpl;
}

const UIImage *tplImg = [UIImage imageNamed:@"item1"];

- (id)initWithController:(UIViewController<NostalgiaCameraDelegate>*)c andImageView:(UIImageView*)iv
{
    delegate = c;
    imageView = iv;
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    videoCamera.rotateVideo = YES;
    videoCamera.defaultFPS = 30;
    videoCamera.delegate = self;
    
    UIImageToMat(tplImg, tpl);
    
    return self;
}

- (void)processImage:(cv::Mat &)img {
    cv::Mat gtpl, gimg;
    
    cv::cvtColor(tpl, gtpl, CV_BGR2GRAY);
    cv::cvtColor(img, gimg, CV_BGR2GRAY);
    
    cv::Mat res(img.rows-tpl.rows+1, tpl.cols-tpl.cols+1, CV_32FC1);
    cv::matchTemplate(gimg, gtpl, res, CV_TM_CCOEFF_NORMED);
    cv::threshold(res, res, 0.5, 1., CV_THRESH_TOZERO);
    
    double minval, maxval, threshold = 0.9;
    cv::Point minloc, maxloc;
    cv::minMaxLoc(res, &minval, &maxval, &minloc, &maxloc);
    
    if (maxval >= threshold)
    {
        cv::rectangle(img, maxloc, cv::Point(maxloc.x + tpl.cols, maxloc.y + tpl.rows), CV_RGB(0,255,0), 2);
        cv::floodFill(res, maxloc, cv::Scalar(0), 0, cv::Scalar(.1), cv::Scalar(1.));
        [delegate matchedItem];
    }
}

- (void)start
{
    [videoCamera start];
}

- (void)stop
{
    [videoCamera stop];
}

@end
