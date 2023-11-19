#!/bin/bash

PIP ?= pip3
SHELL := /bin/bash

target:
	$(info ${HELP_MESSAGE})
	@exit 0

clean: ##=> Deletes current build environment and latest build
	$(info [*] Who needs all that anyway? Destroying environment....)
	rm -rf ./venv/

checkOSDependencies:
	python3 --version || grep "3.10" || (echo "Error: Requires Python 3.10" && exit 1)

all: clean build

install: checkOSDependencies
	${PIP} install virtualenv
	python3 -m venv venv
	. ./venv/bin/activate && ${PIP} install -r tests/requirements.txt

shell:
	. ./venv/bin/activate

deps:
	. ./venv/bin/activate && ${PIP} install -r tests/requirements.txt

coverage:
	. ./venv/bin/activate &&  coverage run -m unittest discover
	. ./venv/bin/activate &&  coverage html --omit "tests/*",".venv/*"

test:
	. ./venv/bin/activate && pytest -v -s tests/

integration:
	. ./venv/bin/activate && pytest -v -s tests/integration

unit:
	. ./venv/bin/activate && pytest -v -s tests/unit

scan:
	. ./venv/bin/activate && bandit -r ./src

#############
#  Helpers  #
#############

define HELP_MESSAGE

	Usage: make <command>

	Commands:

	install   	Install application and dev dependencies defined in requirements.txt
	shell     	Spawn a virtual environment shell
	deps      	Install project dependencies locally
	test      	Run unit test locally using mocks
	integration Run integration test locally using mocks
	unit 				Run unit test locally using mocks
	coverage  	Run unit test coverage reports
	scan	  		Run code scanning tools

	clean     Cleans up local build artifacts and environment
	delete    Delete stack from AWS

endef
