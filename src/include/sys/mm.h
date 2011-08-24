//  IBM_PROLOG_BEGIN_TAG
//  This is an automatically generated prolog.
//
//  $Source: src/include/sys/mm.h $
//
//  IBM CONFIDENTIAL
//
//  COPYRIGHT International Business Machines Corp. 2011
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
#ifndef __SYS_MM_H
#define __SYS_MM_H

#include <stdint.h>
#include <limits.h>
#include <sys/msg.h>

#ifdef __cplusplus
extern "C"
{
#endif

/** @fn mm_alloc_block()
 *  @brief System call to allocate virtual memory block in the base segment
 *
 *  @param[in] mq - Message queue to be associated with the block
 *  @param[in] va - Base virtual address of the block to be allocated
 *  @param[in] size - Requested virtual memory size of the block
 *
 *  @return int - 0 for successful block allocation, non-zero otherwise
 */
int mm_alloc_block(msg_q_t mq,void* va,uint64_t size);

#ifdef __cplusplus
}
#endif

/** @fs mm_icache_invalidate()
 *  @brief Invalidate the ICACHE for the given memory
 *
 *  @param[in] i_addr - Destination address
 *  @param[in] i_cpu_word_count - number of CPU_WORDs (uint64_t)
 */
void mm_icache_invalidate(void * i_addr, size_t i_cpu_word_count);


#endif
