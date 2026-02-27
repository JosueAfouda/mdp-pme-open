# Plateforme Data Moderne Open-Source pour PME

Cette plateforme fournit un socle data packagé, déployé avec Docker Compose, pour une PME qui veut centraliser ses données, les transformer et les visualiser rapidement.

Le MVP actuel couvre :

- ingestion de fichiers plats avec Meltano ;
- stockage dans PostgreSQL ;
- transformations avec dbt ;
- visualisation avec Apache Superset ;
- orchestration disponible avec Airflow ;
- administration technique avec Adminer.

## Cas couvert

Le dépôt contient une démo complète `Stroopwafelshop`, pensée pour être rejouée chez un client PME afin de valider la chaîne data de bout en bout.

Documentation détaillée :

- [Démo Stroopwafelshop](/demo/DEMO_STROOPWAFELSHOP.md)
- [Aperçu métier des données](/demo/data/APERCU_DONNEES.md)
- [Starter kit nouveau client](/demo/STARTER_KIT_NOUVEAU_CLIENT.md)

## Prérequis

- Docker Desktop ou Docker Engine installé et démarré
- Docker Compose disponible via `docker compose`
- fichier `.env` présent à la racine du projet

## Installation rapide

L’installation standard repose sur 4 commandes :

```bash
make up
make load
make bi
make down
```

Signification :

- `make up` : démarre la plateforme data
- `make load` : installe Meltano, charge les données de démonstration et exécute `dbt build`
- `make bi` : démarre et initialise Superset
- `make down` : arrête l’environnement

Commandes utiles :

```bash
make demo
make check
make reset
make dev
```

- `make demo` : rejoue toute la démo de bout en bout
- `make check` : exécute les contrôles SQL de validation
- `make reset` : supprime aussi les volumes Docker
- `make dev` : démarre Adminer pour inspection de PostgreSQL

## Première mise en route

Pour une installation locale ou une démonstration client :

```bash
make up
make load
make bi
```

Accès aux interfaces :

- Airflow : `http://127.0.0.1:18080`
- Superset : `http://127.0.0.1:18088`
- Adminer : `http://127.0.0.1:18081` après `make dev`

Identifiants par défaut :

- Airflow : `admin / admin`
- Superset : `admin / admin`

Connexion PostgreSQL depuis Superset ou Adminer :

- hôte : `postgres`
- port : `5432`
- base : `warehouse`
- utilisateur : `mdp`
- mot de passe : `mdp_password`

## Ce que la plateforme produit

Les données sont organisées dans PostgreSQL par couches :

- `raw` : données brutes ingérées
- `stg` : normalisation et nettoyage
- `mart` : tables analytiques prêtes pour le reporting

Pour la démo Stroopwafelshop, les tables métier principales sont :

- `mart.fct_sales_lines`
- `mart.mart_daily_sales_kpis`
- `mart.mart_product_sales_kpis`

## Validation recommandée

Après chargement, exécuter :

```bash
make check
```

Valeurs de référence attendues sur la démo :

- `sales_revenue = 116773.17`
- `sales_volume = 41745`
- `gross_profit = 78456.760`

## Positionnement PME

Cette version est pensée pour :

- valider rapidement une architecture data moderne open-source ;
- démontrer un cas d’usage métier concret ;
- servir de base de packaging pour une installation client ;
- accélérer les ateliers de cadrage et les POC.

## Limites du MVP

- la démo charge des fichiers CSV, pas encore des sources SaaS ou ERP ;
- Superset nécessite encore quelques actions manuelles pour créer les datasets et le dashboard ;
- Airflow est disponible mais n’est pas utilisé dans le scénario de démonstration standard.

## Arrêt et réinitialisation

Arrêt simple :

```bash
make down
```

Réinitialisation complète :

```bash
make reset
```
