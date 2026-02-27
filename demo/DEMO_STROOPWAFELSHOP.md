# Demo Stroopwafelshop

## Objectif

Cette démonstration valide la plateforme data packagée de bout en bout sur un cas PME simple : un magasin de vente de stroopwafels. Le pipeline couvre :

1. l'ingestion de 6 fichiers CSV avec Meltano ;
2. le chargement des données brutes dans PostgreSQL, schéma `raw` ;
3. les transformations analytiques avec dbt vers les schémas `stg` puis `mart` ;
4. la visualisation des KPI métier dans Apache Superset.

La chaîne complète a été validée sur cette stack :

- ingestion Meltano OK ;
- chargement PostgreSQL OK ;
- `dbt build` OK ;
- Superset démarré et initialisé OK.

Le document métier de référence est [APERCU_DONNEES.md](/home/vant/Documents/business/mdp-pme-open/demo/data/APERCU_DONNEES.md).

## Cas d'usage métier

Le magasin suit ses ventes par transaction et par ligne de vente, ainsi que ses produits, promotions, employés et shifts. Les KPI attendus par un dirigeant PME sont :

- chiffre d'affaires ;
- volume des ventes ;
- bénéfice brut ;
- nombre de transactions par jour ;
- valeur moyenne des transactions.

Dans cette démo :

- le chiffre d'affaires correspond à la somme des montants réellement encaissés (`sales_revenue`) ;
- le volume des ventes correspond à la somme des quantités vendues ;
- le bénéfice brut correspond à `sales_revenue - cogs_amount` ;
- le nombre de transactions correspond au nombre distinct de `sales_id` ;
- la valeur moyenne des transactions correspond à la moyenne du total des tickets.

## Architecture retenue

- Meltano charge les CSV dans `raw`.
- dbt normalise les tables brutes dans `stg` et construit les tables analytiques dans `mart`.
- Superset se connecte directement à PostgreSQL.
- Airflow n'est pas utilisé dans cette démo, car il n'apporte pas de valeur fonctionnelle supplémentaire pour un scénario de démonstration manuel et reproductible. Il peut être ajouté ensuite pour planifier `meltano run` puis `dbt build`.

## Prérequis

- Docker et Docker Compose fonctionnels.
- Fichier `.env` présent à la racine du projet.
- Images du `docker-compose.yml` déjà récupérées ou accessibles.
- `Makefile` présent à la racine du projet pour standardiser le lancement de la démo.

## Données sources

Les fichiers d'entrée se trouvent dans `demo/data` :

- `Employees.csv`
- `Products.csv`
- `Promotions.csv`
- `Sales.csv`
- `Sales_lines.csv`
- `Shifts.csv`

## Commandes standardisées

La démo peut être rejouée avec 4 commandes principales :

```bash
make up
make load
make bi
make down
```

Signification :

- `make up` : démarre la plateforme data (`postgres`, `meltano`, `dbt`, `airflow`) ;
- `make load` : installe les plugins Meltano, charge les 6 CSV puis exécute `dbt build` ;
- `make bi` : démarre et initialise Superset ;
- `make down` : arrête l'environnement.

Commandes utiles en complément :

```bash
make demo
make dev
make check
make reset
```

- `make demo` : rejoue la démo complète avec contrôles SQL finaux ;
- `make dev` : démarre Adminer pour inspecter PostgreSQL ;
- `make check` : exécute les requêtes SQL de validation ;
- `make reset` : arrête l'environnement et supprime les volumes.

## Démarrage de la plateforme

Lancer les composants data :

```bash
make up
```

Vérifier l'état :

```bash
docker compose --profile core ps
```

## Étape 1. Installer les plugins Meltano

Cette étape est à faire une première fois, ou à refaire si le cache Docker des plugins a été supprimé :

```bash
docker compose --profile core run --rm meltano install
```

## Étape 2. Ingestion des 6 CSV dans PostgreSQL

Lancer l'ingestion :

```bash
docker compose --profile core run --rm meltano run tap-csv target-postgres
```

Résultat attendu :

- création du schéma `raw` ;
- chargement des tables `raw.employees`, `raw.products`, `raw.promotions`, `raw.sales`, `raw.sales_lines`, `raw.shifts`.

Contrôle rapide dans PostgreSQL via Adminer en mode dev :

```bash
make dev
```

Ouvrir `http://127.0.0.1:18081` puis se connecter avec :

- Système : `PostgreSQL`
- Serveur : `postgres`
- Utilisateur : `mdp`
- Mot de passe : `mdp_password`
- Base : `warehouse`

Exemples de contrôles SQL :

```sql
select table_schema, table_name
from information_schema.tables
where table_schema in ('raw', 'stg', 'mart')
order by table_schema, table_name;
```

```sql
select count(*) from raw.sales;
```

```sql
select count(*) from raw.sales_lines;
```

## Étape 3. Construire les modèles dbt

Valider la connexion dbt :

```bash
docker compose --profile core run --rm dbt debug
```

Exécuter les transformations et les tests :

```bash
docker compose --profile core run --rm dbt build
```

Résultat attendu :

- vues `stg.*` ;
- tables `mart.*` ;
- tests de cohérence sur les clés et relations.

Tables analytiques principales produites :

- `mart.dim_employees`
- `mart.dim_products`
- `mart.dim_promotions`
- `mart.dim_shifts`
- `mart.fct_sales_lines`
- `mart.mart_daily_sales_kpis`
- `mart.mart_product_sales_kpis`

## KPI calculés dans dbt

### 1. Chiffre d'affaires

Source : `mart.fct_sales_lines.sales_revenue`

Formule :

```sql
sum(sales_revenue)
```

### 2. Volume des ventes

Source : `mart.fct_sales_lines.quantity_sold`

Formule :

```sql
sum(quantity_sold)
```

### 3. Bénéfice brut

Source : `mart.fct_sales_lines.gross_profit`

Formule :

```sql
sum(gross_profit)
```

Avec :

```sql
gross_profit = sales_revenue - cogs_amount
```

et :

```sql
cogs_amount = quantity_sold * unit_cost
```

### 4. Nombre de transactions par jour

Source : `mart.mart_daily_sales_kpis.number_of_transactions`

Formule dbt :

```sql
count(distinct sales_id)
```

agrégé par `sold_date`.

### 5. Valeur moyenne des transactions

Source : `mart.mart_daily_sales_kpis.average_transaction_value`

Formule dbt :

```sql
avg(total_price)
```

calculée sur les tickets de caisse (`stg_sales`).

## Étape 4. Démarrer Superset

Lancer la BI :

```bash
make bi
```

Accéder à l'interface :

- URL : `http://127.0.0.1:18088`
- Login : `admin`
- Mot de passe : `admin`

## Étape 5. Actions manuelles dans Superset

Les actions ci-dessous doivent être réalisées manuellement dans l'interface Superset.

### 5.1 Ajouter la connexion PostgreSQL

1. Aller dans `Settings` > `Database Connections`.
2. Cliquer sur `+ Database`.
3. Choisir `PostgreSQL`.
4. Renseigner l'URI SQLAlchemy :

```text
postgresql+psycopg2://mdp:mdp_password@postgres:5432/warehouse
```

5. Tester la connexion.
6. Sauvegarder.

Le driver PostgreSQL est présent dans l'image Superset validée pour cette démo.

### 5.2 Créer les datasets

Créer au minimum les datasets suivants :

1. `mart.mart_daily_sales_kpis`
2. `mart.mart_product_sales_kpis`
3. `mart.fct_sales_lines`

Pour chacun :

1. Aller dans `Data` > `Datasets`.
2. Cliquer sur `+ Dataset`.
3. Choisir la base PostgreSQL créée.
4. Sélectionner le schéma `mart`.
5. Sélectionner la table.
6. Sauvegarder.

Configurer les champs temporels :

- dataset `mart_daily_sales_kpis` : colonne temporelle `sold_date`
- dataset `mart_product_sales_kpis` : colonne temporelle `sold_date`
- dataset `fct_sales_lines` : colonne temporelle `sold_at`

### 5.3 Construire le dashboard métier

Créer un dashboard `Stroopwafelshop - Vue dirigeant PME`.

Créer les graphiques suivants :

1. `KPI - Chiffre d'affaires`
   Source : `mart_daily_sales_kpis`
   Type : Big Number
   Mesure : `sum(sales_revenue)`

2. `KPI - Volume des ventes`
   Source : `mart_daily_sales_kpis`
   Type : Big Number
   Mesure : `sum(sales_volume)`

3. `KPI - Bénéfice brut`
   Source : `mart_daily_sales_kpis`
   Type : Big Number
   Mesure : `sum(gross_profit)`

4. `Transactions par jour`
   Source : `mart_daily_sales_kpis`
   Type : Time-series Bar Chart
   Axe temps : `sold_date`
   Mesure : `sum(number_of_transactions)`

5. `Valeur moyenne des transactions`
   Source : `mart_daily_sales_kpis`
   Type : Time-series Line Chart
   Axe temps : `sold_date`
   Mesure : `avg(average_transaction_value)`

6. `Volume des ventes par type de gaufre`
   Source : `mart_product_sales_kpis`
   Type : Bar Chart
   Dimension : `product_name`
   Mesure : `sum(sales_volume)`

7. `Chiffre d'affaires par type de gaufre`
   Source : `mart_product_sales_kpis`
   Type : Bar Chart
   Dimension : `product_name`
   Mesure : `sum(sales_revenue)`

Ajouter un filtre global de date basé sur `sold_date`.

## Validation SQL recommandée

Exécuter ces requêtes dans PostgreSQL pour valider les KPI :

```sql
select
  sum(sales_revenue) as sales_revenue,
  sum(quantity_sold) as sales_volume,
  sum(gross_profit) as gross_profit
from mart.fct_sales_lines;
```

Résultat de référence sur les données fournies :

- `sales_revenue = 116773.17`
- `sales_volume = 41745`
- `gross_profit = 78456.760`

```sql
select
  sold_date,
  number_of_transactions,
  average_transaction_value
from mart.mart_daily_sales_kpis
order by sold_date;
```

```sql
select
  product_name,
  sum(sales_volume) as sales_volume,
  sum(sales_revenue) as sales_revenue
from mart.mart_product_sales_kpis
group by 1
order by 2 desc;
```

Résultat de référence :

- `Classic Stroopwafel` : `24281` unités, `59542.50` de CA
- `Vanilla Stroopwafel` : `10849` unités, `37444.80` de CA
- `Honey Stroopwafel` : `6615` unités, `19785.87` de CA

## Rejeu complet de la démo

Ordre recommandé :

```bash
make reset
make up
make load
make bi
make check
```

Version en une seule commande :

```bash
make demo
```

## Nettoyage

Arrêter l'environnement :

```bash
make down
```

Supprimer aussi les volumes si un reset complet est nécessaire :

```bash
make reset
```
