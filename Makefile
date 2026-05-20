.PHONY: run

run: build
	open -a "Playdate Simulator" LostRaturn.pdx

build:
	pdc Source LostRaturn.pdx

