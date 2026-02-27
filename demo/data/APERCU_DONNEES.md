# Regard sur les données pour avoir un aperçu plus précis des opérations quotidiennes du magasin

Vous avez conseillé à Jan de demander au fournisseur l'historique complet des ventes, ainsi que toutes les autres informations utiles collectées par le POS. Le fournisseur crée un extrait manuel de sa base de données dans des feuilles de calcul et l'envoie par e-mail à Jan, qui les télécharge ensuite dans Google Sheets pour vous les communiquer. Nous examinerons d'abord les feuilles de calcul, en nous concentrant sur les cinq ensembles de données suivants : Sales (ventes), Sales lines (lignes de vente), Employees (employés), Products (produits) et Promotions. 

## Dataset des ventes (Sales)

Chaque ligne correspond à une vente en magasin. L'analyse des colonnes permet d'identifier : sales_id, date, time, weekday, employee_id, total_price, total_discount, weekday et payment_type. Ces attributs fournissent des informations sur la date et l'heure de la vente, ainsi que sur le mode de paiement. Des méta-attributs ou clés, tels que sales_id et employee_id, nous renseignent également sur les données elles-mêmes.

Il semble que chaque vente soit suivie par une valeur sales_id. En l'observant, vous pouvez constater qu'il s'agit d'un nombre incrémentiel, probablement généré automatiquement pour chaque vente. De plus, employee_id suggère des informations supplémentaires sur les employés en dehors de l'ensemble de données Sales. Il existe probablement une autre table contenant ces informations, qui peut être connectée via employee_id.

Il aurait été possible d'ajouter toutes les informations relatives à un employé (par exemple, son nom complet et sa date de naissance) dans chaque enregistrement de vente, mais comme chaque employé réalise plusieurs ventes par jour, cela entraînerait de nombreuses duplications. La séparation des données dans des tables individuelles, telles que Ventes et Employés, pour éviter une telle duplication est appelée normalisation.

**N.B** : La normalisation des bases de données est une technique courante pour minimiser la duplication des données dans chaque table et est très courante dans les systèmes de traitement des transactions en ligne (OLTP) tels que les systèmes PoS.

## Dataset des employés (Employees)

Puisque nous disposons du jeu de données Employés, nous pouvons l'examiner rapidement pour confirmer nos soupçons :

L'extrait du jeu de données Employés confirme ce fait. Il existe 10 identifiants, un pour chaque employé travaillant dans le magasin. Cela signifie que la valeur employee_id du jeu de données Ventes correspond à celle qui gère la vente, et des informations complémentaires doivent être extraites du jeu de données Employés. Ces informations sont importantes pour l'extraction automatisée des données de la feuille de calcul, car elles nous permettent de comprendre les relations entre les jeux de données et la conception de la base de données source. Nous pourrons ensuite joindre ces deux jeux de données à l'aide de ces champs et enrichir chaque enregistrement de vente avec des informations supplémentaires sur l'employé.

## Dataset des lignes de ventes (Sales Lines)

Dans la feuille de calcul « Lignes de vente », nous constatons que chaque vente de l'ensemble de données « Ventes » est divisée en plusieurs lignes de vente définissant la quantité de chaque produit vendue. Cela indique que, dans la base de données source, les lignes de vente sont stockées dans une table différente de celle des enregistrements de vente.

## Dataset des lignes de produits (Products)

En examinant maintenant la feuille de calcul « Produits », nous constatons que Jan vend trois types de Stroopwafels : classic, vanilla et honey.

Chacun de ces Stroopwafels correspond à un identifiant unique et peut être lié à une autre table (exemple la table des lignes de ventes) grâce à cette clé unique. Vous rencontrerez probablement des conceptions de données similaires avec les systèmes OLTP, et elles constituent la base de la technique de modélisation dimensionnelle, que nous utiliserons plus loin dans ce projet pour modéliser les données. Pour l'instant, il suffit de comprendre que la séparation des événements et des entités métier, comme une vente ou un employé, dans des tables distinctes et leur référencement par des clés uniques est un élément essentiel des systèmes de bases de données que vous rencontrerez en entreprise.

## Dataset des horaires quotidiens (Shifts) de chaque employé

Entre-temps, vous remarquez avoir reçu un e-mail de Jan. Il affirme qu'il aurait dû mentionner qu'il dispose d'une feuille de calcul contenant les quarts de travail quotidiens de chaque employé, qu'il suit manuellement, et se demande si cela vous intéresse également. Absolument ! Vous lui demandez de partager cela également, ce qu'il fait :

Comme nous le voyons, une journée peut comporter deux quarts : le quart du matin de 10 h à 14 h et celui de l'après-midi de 14 h à 18 h. Il semble que deux employés travaillent ensemble par quart : un caissier et un boulanger. De plus, nous pouvons maintenant supposer que la valeur employee_id correspondra aux données Employees pour savoir quel employé travaillait à ce moment-là. Cela vous permettra de comptabiliser le nombre total d'heures travaillées par les employés, ainsi que le volume de ventes qu'ils ont réalisé ensemble.

Nous venons d'obtenir un aperçu plus précis des opérations quotidiennes du magasin. Pour l'instant, nous allons commencer à transférer les données dans notre entrepôt de données (datawarehouse).
