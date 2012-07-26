//
//  MemoryAllocation.js
//  UnitTests
//
//  Created by Logan Collins on 7/25/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

function main() {
	var iterations = 100000;
	
	var array = NSMutableArray.alloc().init();
	
	for (var i=0; i<iterations; i++) {
		var dict = NSMutableDictionary.alloc().init();
		
		dict.setObject_forKey_("foobar", "string");
		dict.setObject_forKey_(100, "integer");
		dict.setObject_forKey_(true, "boolean");
		dict.setObject_forKey_(NSDate.date(), "date");
		
		array.addObject_(dict);
		
		dict.release();
	}
	
	var count = array.count();
	
	array.release();
	array = null;
	
	var result = null;
	if (count == iterations) {
		result = [true, null];
	}
	else {
		result = [false, "Number of iterations to created objects is inconsistent"];
	}
	return result;
}
