//
//  UpdateAttachmentsProtocol.h
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-13.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#ifndef zSMTH_UpdateAttachmentsProtocol_h
#define zSMTH_UpdateAttachmentsProtocol_h

@protocol UpdateAttachmentsProtocol <NSObject>

@required
-(void) updateAttachments:(NSArray*) attachments;

@end

#endif
