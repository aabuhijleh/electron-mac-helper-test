#import <Foundation/Foundation.h>

@interface Box : NSObject {
  double length;  // Length of a box
  double breadth; // Breadth of a box
  double height;  // Height of a box
}

@property(nonatomic, readwrite) double height; // Property
- (double)volume;
@end

@implementation Box

@synthesize height;

- (id)init {
  self = [super init];
  length = 1.0;
  breadth = 1.0;
  return self;
}

- (double)volume {
  return length * breadth * height;
}

@end