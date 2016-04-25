PWD=$(shell pwd)

.PHONY: script supervisor

script:
	chmod 755 $(PWD)/script/*
	cp $(PWD)/script/* $(PWD)/../wiringPi/examples
	
supervisor:
	cp $(PWD)/supervisor/* /etc/supervisor/conf.d