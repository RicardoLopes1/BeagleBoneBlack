CROSS_COMPILE ?= arm-linux-gnueabihf-

all: lab.s
	$(CROSS_COMPILE)as lab.s -o lab.o
	$(CROSS_COMPILE)objcopy lab.o lab.bin -O binary
	$(CROSS_COMPILE)objdump -D -b binary -marm lab.bin > lab.lst
	cp *.bin /tftpboot


clean:
	rm *.o *.bin *.lst
