CROSS_COMPILE ?= arm-linux-gnueabihf-

all: gpio.s
	$(CROSS_COMPILE)as gpio.s -o gpio.o
	$(CROSS_COMPILE)objcopy gpio.o gpio.bin -O binary
	$(CROSS_COMPILE)objdump -D -b binary -marm gpio.bin > gpio.lst
	cp *.bin /tftpboot


clean:
	rm *.o *.bin *.lst
