//
//  CoreGraphics.js
//  UnitTests
//
//  Created by Logan Collins on 7/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

framework("CoreGraphics");


function main() {
    var fm = NSFileManager.defaultManager();
    
    var url = NSURL.fileURLWithPath("/tmp/foo.pdf");
    fm.removeItemAtURL_error(url, null);
    
    var rect = CGRectMake(0.0, 0.0, 100.0, 100.0);
    var rectPtr = Pointer(rect);
    var c = CGPDFContextCreateWithURL(url, rect, null);
    
    CGPDFContextBeginPage(c, null);
    
    var redColor = CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0);
    CGContextSetFillColorWithColor(c, redColor);
    CGContextFillRect(c, NSMakeRect(0.0, 0.0, 50.0, 50.0));
    CGColorRelease(redColor);
    
    var greenColor = CGColorCreateGenericRGB(0.0, 1.0, 0.0, 1.0);
    CGContextSetFillColorWithColor(c, redColor);
    CGContextFillRect(c, NSMakeRect(50.0, 0.0, 25.0, 50.0));
    CGColorRelease(greenColor);
    
    var blueColor = CGColorCreateGenericRGB(0.0, 0.0, 1.0, 1.0);
    CGContextSetFillColorWithColor(c, redColor);
    CGContextFillRect(c, NSMakeRect(25.0, 25.0, 25.0, 25.0));
    CGColorRelease(blueColor);
    
    CGPDFContextEndPage(c);
    
    CGPDFContextClose(c);
    CGContextRelease(c);
    
    return NSArray.arrayWithObjects(true, null);
}
