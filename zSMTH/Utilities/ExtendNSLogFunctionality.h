// Quick Tip: Customize NSLog for Easier Debugging
// http://code.tutsplus.com/tutorials/quick-tip-customize-nslog-for-easier-debugging--mobile-19066
#import <Foundation/Foundation.h>
 
#ifdef DEBUG
#define NSLog(args...) ExtendNSLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args); 
#else
#define NSLog(x...)
#endif
 
void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);
