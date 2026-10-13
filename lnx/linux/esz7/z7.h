/* SPDX-License-Identifier: GPL-2.0-only */
/*
 *  \brief  Z7 driver
 *  \author Aleksey Lekhtin
 *  \date   2025-09-25
 *  \copyright Copyright 2024-2025 
 */

#ifndef Z7__H__
#define Z7__H__

#include <linux/dynamic_debug.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/of_device.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/spinlock.h>

#include <linux/ktime.h>
#include <linux/rtc.h>

#define MODULE_NAME "Z7"
#define MODULE_VERS "3.0.0 Dec 25 2025"

extern unsigned int debug_level;

void get_rtc_time(ktime_t *kt, struct rtc_time *t);
int z7_create_sysfs_attributes(struct device *dev);
void z7_remove_sysfs_attributes(struct device *dev);

struct Z7 {
	struct device *dev;
	void __iomem *iomem;
	void __iomem *addr_ctrl;
	void __iomem *addr_stat;
	void __iomem *addr_adc;
	const char *of_name;
	const char *of_version;
	const char *of_compatible;
	u32 of_reg;
	u32 of_interrupts[3*4];
	int irqs[4]; // index of IRQ cell in linux kernel
};

#endif //Z7__H__
