.PHONY: clean format analyze run check get

clean:
	flutter clean

get:
	flutter pub get

format:
	dart format .

analyze:
	flutter analyze 

run: format
	flutter pub get
	flutter run

check: clean get format analyze