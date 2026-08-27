.PHONY: clean format analyze run check get
.DEFAULT_GOAL := goncalo

clean:
	flutter clean

get:
	flutter pub get

format:
	dart format .

analyze:
	flutter analyze 

run: 
	flutter run

check: get format analyze

goncalo: check run