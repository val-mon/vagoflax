.PHONY: help clean get format analyze run check goncalo

.DEFAULT_GOAL := help

help: ## Affiche la liste des commandes disponibles
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_-]+:.*##/ {printf "  %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

clean: ## Supprime les fichiers générés par Flutter
	flutter clean

get: ## Installe les dépendances Flutter
	flutter pub get

format: ## Formate le code Dart
	dart format .

analyze: ## Analyse statiquement le projet
	flutter analyze

run: ## Lance l'application Flutter
	flutter run

check: get format analyze ## Installe, formate et analyse le projet

goncalo: check run ## Vérifie le projet puis lance l'application