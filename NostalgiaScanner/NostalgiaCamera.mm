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
    cv::Mat gtpl;
}

- (id)initWithController:(UIViewController<NostalgiaCameraDelegate>*)c andImageView:(UIImageView*)iv
{
    delegate = c;
    imageView = iv;
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView]; // Init with the UIImageView from the ViewController
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; // Ensure proper orientation
    videoCamera.rotateVideo = YES; // Ensure proper orientation
    videoCamera.defaultFPS = 30; // How often 'processImage' is called, adjust based on the amount/complexity of images
    videoCamera.delegate = self;
    
    // Convert UIImage to Mat and store greyscale version
    UIImage *tplImg = [UIImage imageNamed:@"item1"];
    cv::Mat tpl;
    UIImageToMat(tplImg, tpl);
    cv::cvtColor(tpl, gtpl, CV_BGR2GRAY);
    
    return self;
}

- (void)processImage:(cv::Mat &)img {
    cv::Mat gimg;
    
    // Convert incoming img to greyscale to match template
    cv::cvtColor(img, gimg, CV_BGR2GRAY);
    
    // Check for matches with a certain threshold to help with scaling and angles
    cv::Mat res(img.rows-gtpl.rows+1, gtpl.cols-gtpl.cols+1, CV_32FC1);
    cv::matchTemplate(gimg, gtpl, res, CV_TM_CCOEFF_NORMED);
    cv::threshold(res, res, 0.5, 1., CV_THRESH_TOZERO);
    
    double minval, maxval, threshold = 0.9;
    cv::Point minloc, maxloc;
    cv::minMaxLoc(res, &minval, &maxval, &minloc, &maxloc);
    
    // If it's a good enough match
    if (maxval >= threshold)
    {
        // Draw a rectangle for confirmation
        cv::rectangle(img, maxloc, cv::Point(maxloc.x + gtpl.cols, maxloc.y + gtpl.rows), CV_RGB(0,255,0), 2);
        cv::floodFill(res, maxloc, cv::Scalar(0), 0, cv::Scalar(.1), cv::Scalar(1.));
        
        // Call our delegates callback method
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
