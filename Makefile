.PHONY: run build clean validate format

run: build
	open -a "Playdate Simulator" LostRaturn.pdx

build:
	pdc source LostRaturn.pdx

clean:
	rm -rf LostRaturn.pdx

validate:
	stylua --check source/
	lua-language-server --check .

format:
	stylua source/
