.PHONY: run build clean

run: build
	open -a "Playdate Simulator" LostRaturn.pdx

build:
	pdc source LostRaturn.pdx

clean:
	rm -rf LostRaturn.pdx
