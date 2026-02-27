include .env
export

COMPOSE := docker compose
CORE := --profile core
BI := --profile bi
DEV := --profile dev

.DEFAULT_GOAL := help

.PHONY: help up load bi dev demo check down reset

help:
	@printf "Commandes principales:\n"
	@printf "  make up    - demarre la plateforme data (Postgres, Meltano, dbt, Airflow)\n"
	@printf "  make load  - installe Meltano, charge les CSV et construit les modeles dbt\n"
	@printf "  make bi    - demarre et initialise Superset\n"
	@printf "  make down  - arrete l'environnement\n"
	@printf "\nCommandes utiles:\n"
	@printf "  make demo  - rejoue la demo complete\n"
	@printf "  make dev   - demarre Adminer\n"
	@printf "  make check - execute des controles SQL de validation\n"
	@printf "  make reset - arrete et supprime les volumes\n"

up:
	$(COMPOSE) $(CORE) up -d

load:
	$(COMPOSE) $(CORE) run --rm meltano install
	$(COMPOSE) $(CORE) run --rm meltano run tap-csv target-postgres
	$(COMPOSE) $(CORE) run --rm dbt build

bi:
	$(COMPOSE) $(BI) up -d
	$(COMPOSE) $(BI) run --rm superset_init

dev:
	$(COMPOSE) $(DEV) up -d

demo: up load bi check

check:
	$(COMPOSE) exec -T postgres psql -U $(PG_USER) -d $(PG_DB) -c "select table_schema, table_name from information_schema.tables where table_schema in ('raw', 'stg', 'mart') order by table_schema, table_name;"
	$(COMPOSE) exec -T postgres psql -U $(PG_USER) -d $(PG_DB) -c "select sum(sales_revenue) as sales_revenue, sum(quantity_sold) as sales_volume, sum(gross_profit) as gross_profit from mart.fct_sales_lines;"
	$(COMPOSE) exec -T postgres psql -U $(PG_USER) -d $(PG_DB) -c "select product_name, sum(sales_volume) as sales_volume, sum(sales_revenue) as sales_revenue from mart.mart_product_sales_kpis group by 1 order by 2 desc;"

down:
	$(COMPOSE) down

reset:
	$(COMPOSE) down -v
