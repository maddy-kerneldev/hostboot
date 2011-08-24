//  IBM_PROLOG_BEGIN_TAG
//  This is an automatically generated prolog.
//
//  $Source: src/include/string.h $
//
//  IBM CONFIDENTIAL
//
//  COPYRIGHT International Business Machines Corp. 2010 - 2011
//
//  p1
//
//  Object Code Only (OCO) source materials
//  Licensed Internal Code Source Materials
//  IBM HostBoot Licensed Internal Code
//
//  The source code for this program is not published or other-
//  wise divested of its trade secrets, irrespective of what has
//  been deposited with the U.S. Copyright Office.
//
//  Origin: 30
//
//  IBM_PROLOG_END
#ifndef __STRING_H
#define __STRING_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" 
{
#endif

    void *memset(void* s, int64_t c, size_t n);
    void bzero(void *vdest, size_t len);
    void *memcpy(void *dest, const void *src, size_t num);
    void *memmove(void *vdest, const void *vsrc, size_t len);
    int64_t memcmp(const void *p1, const void *p2, size_t len);

    char* strcpy(char* d, const char* s);
    int strcmp(const char* s1, const char* s2);
    size_t strlen(const char* s1);

#ifdef __cplusplus
};
#endif

#endif
