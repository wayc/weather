PWD=$(shell pwd)

.PHONY: script supervisor

script:
	cp $(PWD)/script/* $(PWD)/../wiringPi/examples
	chmod 750 $(PWD)/../wiringPi/examples/*
	
supervisor:
	cp $(PWD)/supervisor/* /etc/supervisor/conf.d