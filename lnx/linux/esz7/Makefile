KDIR ?= /lib/modules/$(shell uname -r)/build

all: z7.ko

z7.ko:
	$(MAKE) -C $(KDIR) M=$(PWD)

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

defconfig:
	echo "# " > .config
