PWD=$(shell pwd)

all:
	cp $(PWD)/script/* $(PWD)/../wiringPi/examples
	cp $(PWD)/supervisor/* /etc/supervisor/conf.d
