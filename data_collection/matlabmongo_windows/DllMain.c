/**    Copyright 2009-2011 10gen Inc.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
#ifdef _WIN32
#include <windows.h>
#endif

#include "bson.h"
#include <mex.h>

extern int sock_init();


int main(void)
{
    sock_init();
    bson_printf = mexPrintf;
    bson_errprintf = mexPrintf;
    set_bson_err_handler(mexErrMsgTxt);
    return 0;
}

#ifdef _WIN32
BOOL APIENTRY DllMain(HMODULE hModule,
                      DWORD  ul_reason_for_call,
                      LPVOID lpReserved)
{
    main();
    return TRUE;
}
#endif
