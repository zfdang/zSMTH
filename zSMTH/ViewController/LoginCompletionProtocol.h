//
//  LoginCompletionProtocol.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-3-19.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#ifndef zSMTH_LoginCompletionProtocol_h
#define zSMTH_LoginCompletionProtocol_h

@protocol LoginCompletionProtocol <NSObject>

@required
-(void) refreshViewAfterLogin;

@end

#endif
