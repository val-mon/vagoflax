.PHONY: help clean get format analyze test run check goncalo mock_data

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

test: ## Lance les tests unitaires
	flutter test

check: get format analyze test ## Installe, formate et analyse le projet

goncalo: check run ## Vérifie le projet puis lance l'application

mock_data: ## Creates mock data for the database
	@node -e "if (!require('fs').existsSync('mock_data/serviceAccountKey.json')) { console.error('serviceAccountKey.json is missing in mock_data/.'); process.exit(1); }"
	@echo Creating mock data for the database...
	@npm --prefix mock_data install
	@node mock_data/fill_db_mockup_data.js