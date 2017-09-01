//
//  ServerApi.h
//  DLDQ_IOS
//
//  Created by simman on 14-8-19.
//  Copyright (c) 2014年 Liwei. All rights reserved.
//

#ifndef DLDQ_IOS_ServerApi_h
#define DLDQ_IOS_ServerApi_h

// --------------------------------- 服务器 ---------------------------------

//#import "URLManager.h"

#ifdef DEBUG

//#define NSLog(...) LogMessageF( __FILE__,__LINE__,__FUNCTION__, NULL, 0, __VA_ARGS__)

#define API_STAR_PAGE       [NSString stringWithFormat:@"%@%@", [[logicShareInstance getURLManager] getBaseURL], @"/appuser/detail/markscore"]
#define API_USER_WALLET     [NSString stringWithFormat:@"%@%@", [[logicShareInstance getURLManager] getBaseURL], @"/finance/mywallet?userId="]

#else

#define NSLog(...) {};

#define API_STAR_PAGE       [NSString stringWithFormat:@"%@%@", [[logicShareInstance getURLManager] getBaseURL], @"/appuser/detail/markscore"]
#define API_USER_WALLET     [NSString stringWithFormat:@"%@%@", [[logicShareInstance getURLManager] getBaseURL], @"/finance/mywallet?userId="]
#endif


#define HOST_NAME   @"www.baidu.com"
#define SERVER_EMAIL        @"serve@dldq.org"
#define API_Privacy         [NSString stringWithFormat:@"%@/%@",[[logicShareInstance getURLManager] getNoServerBaseURL], @"protocol.action?from=ios"]
#define API_Agreement       [NSString stringWithFormat:@"%@/%@",[[logicShareInstance getURLManager] getNoServerBaseURL], @"protocol.action?from=ios"]


#endif
