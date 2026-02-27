# Client Template

Ce template sert de base pour un nouveau client.

## 1) Copier le template

```bash
cp -R projects/client_template projects/<nom_client>
```

## 2) Ajouter les données

Déposer les fichiers sources dans `projects/<nom_client>/data`.

## 3) Adapter Meltano

Partir de `projects/<nom_client>/meltano/meltano.client.template.yml` et reporter la configuration dans `meltano/meltano.yml`.

## 4) Adapter dbt

Partir des modèles SQL de `projects/<nom_client>/dbt/models`.

## 5) Lancer le pipeline

```bash
make up
make load
make bi
make check
```
