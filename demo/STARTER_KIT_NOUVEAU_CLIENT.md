# Starter Kit Nouveau Client

## Objectif

Ce document décrit la procédure standard pour démarrer un nouveau projet client sur la plateforme, tout en conservant la capacité de rejouer la démo `Stroopwafelshop`.

## Réponse courte à ta question

Oui, ton intuition est bonne :

- il faut **réinitialiser l'exécution** (containers + volumes + données chargées) pour repartir propre ;
- il ne faut pas supprimer la démo du dépôt ;
- il faut isoler le nouveau projet pour pouvoir rejouer la démo à tout moment.

La bonne pratique est donc : **reset data/runtime + versionnement Git**, pas suppression définitive.

## Modèle de travail recommandé

1. Garder une référence stable de la démo :
```bash
git tag -a demo-stroopwafelshop-stable -m "Reference demo validated"
```

2. Créer une branche dédiée au client :
```bash
git switch -c client/<nom_client>
```

3. Réinitialiser l'environnement d'exécution :
```bash
make reset
```

Avec ce modèle :

- la branche client est propre pour construire le nouveau cas ;
- la démo reste rejouable via le tag ou la branche de référence.

## Checklist de démarrage (nouveau client)

1. Créer un dossier client :
```bash
mkdir -p projects/<nom_client>/{data,docs}
```

2. Placer les fichiers source du client dans :
```text
projects/<nom_client>/data
```

3. Adapter l'ingestion dans [meltano.yml](/home/vant/Documents/business/mdp-pme-open/meltano/meltano.yml#L1) :
- nouveaux streams/fichiers ;
- clés primaires ;
- mapping de colonnes ;
- chargement vers le schéma `raw`.

4. Adapter les volumes du service `meltano` dans [docker-compose.yml](/home/vant/Documents/business/mdp-pme-open/docker-compose.yml#L50) pour monter le dossier data client (lecture seule), par exemple :
```yaml
- ./projects/<nom_client>/data:/project/projects/<nom_client>/data:ro
```

5. Construire les modèles dbt dans [dbt](/home/vant/Documents/business/mdp-pme-open/dbt#L1) :
- `stg_*` : normalisation ;
- `mart_*` : KPI métier ;
- tests de qualité (`not_null`, `unique`, `relationships`).

6. Démarrer et exécuter la chaîne :
```bash
make up
make load
make bi
make check
```

7. Construire les datasets/charts Superset pour le client.

8. Documenter le projet client dans :
```text
projects/<nom_client>/docs
```

## Convention de schémas conseillée

- `raw` : données brutes ingérées ;
- `stg` : standardisation technique ;
- `mart` : tables KPI métier.

Si plusieurs clients coexistent dans la même base, utiliser des schémas préfixés (ex. `raw_clienta`, `stg_clienta`, `mart_clienta`) ou des bases séparées.

## Réinitialisation propre (sans perdre la démo)

Réinitialiser uniquement l'environnement :

```bash
make reset
```

Cette commande :

- arrête les services ;
- supprime les volumes Docker ;
- efface les données chargées en base.

Elle ne supprime pas le code, ni les fichiers de démo, ni la documentation.

## Rejouer la démo Stroopwafelshop plus tard

Option A (si tu es sur la branche client) :

```bash
git switch <branche_demo_ou_main>
make demo
```

Option B (référence figée par tag) :

```bash
git switch --detach demo-stroopwafelshop-stable
make demo
```

## Garde-fous importants

- Ne pas écraser `demo/data` avec les données client.
- Ne pas développer un projet client directement sur une branche non isolée.
- Toujours lancer `make reset` avant un nouveau chargement majeur.
- Valider les KPI avec `make check` avant de passer à Superset.

## Livrables minimum d'un nouveau projet client

- configuration Meltano à jour ;
- modèles dbt `stg` et `mart` ;
- tests dbt passants ;
- dashboard Superset métier ;
- documentation projet (`sources`, `règles KPI`, `mode opératoire`).
