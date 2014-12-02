//
//  MemoryAllocation.js
//  UnitTests
//
//  Created by Logan Collins on 7/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

function main() {
    var iterations = 100000;
    
    var array = NSMutableArray.array();
    
    for (var i=0; i<iterations; i++) {
        var dict = NSMutableDictionary.array();
        
        dict.setObject_forKey("foobar", "string");
        dict.setObject_forKey(100, "integer");
        dict.setObject_forKey(true, "boolean");
        dict.setObject_forKey(NSDate.date(), "date");
        
        array.addObject(dict);
    }
    
    var count = array.count();
    
    var result = null;
    if (count == iterations) {
        result = NSArray.arrayWithObjects(true, null);
    }
    else {
        result = NSArray.arrayWithObjects(false, "Number of iterations to created objects is inconsistent");
    }
    return result;
}
