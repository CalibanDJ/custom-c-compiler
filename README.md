# Résumé

Le projet de compilation a pour objet la réalisation d'un compilateur d'un mini langage appelé pour l'occasion myC vers du code C à 3 adresses. Le langage source proposé, un mini langage C, devra donc être compilé en C à 3 adresses.

Il a été réalisé par le groupe GCC-de-fonctionner composé de Genty Laurent et Chataigner Johan, élèves à l'Enseirb-Matmeca en deuxième année informatique.

# Pré-requis

Afin de faire fonctionner ce projet vous devez posséder les packages suivants :
- make
- gcc
- flex
- bison

# Dossiers et contenu

Le projet s'organise de la sorte :
  - `src/` : sources générant le compilateur `myc`
    * `Attribute.c` et `Attribute.h` : permet de gérer les attributs (entier, flottants, ...) dans l'analyse de types et noms.
    * `Table_des_chaines.c` et `Table_des_chaines.h` : permet de récupérer les noms lors de l'analyse de noms
    * `Table_des_symboles.c` et `Table_des_symboles.h` : permet de générer des éléments dans la table des symboles regroupant toutes les variables attributs créés et garder en mémoire leur valeur, type, ... sous forme de liste chaînée
    * `lang.y` : syntaxe du compilateur `myc`
    * `lang.l` : lexique de compilateur `myc`
  - `test/` : fichiers tests du compilateur `myc`
    * `test.myc` : fichier contenant des instructions basiques permettant de verifier que les fonctions de base de l'application sont implémentées
  - `Makefile`
  - `compil.sh` : script shell permettant de générer le compilateur et compiler le fichier `.myc` donné en argument en `.c` et `.h`
  - `README.md`

# Compilation et exécution

Afin de pouvoir compiler notre programme et l'utiliser, plusieurs règles du `Makefile` peuvent être utiles :
  - `make clean` : permet de nettoyer avant de compiler tous les fichiers produits durant la compilation
  - `make` : compiler tous les sources permettant de créer le compilateur `myc`
  - `make test` : compiler le fichier `test/test.myc` avec notre compilateur et générer les fichiers `.c` et `.h` correspondants

Cependant, nous avons mis en place un script permettant d'automatiser toutes ces étapes, le script `compil.sh`. En exécutant ce script avec la commande `./compil <fichier.myc>`, il va effectuer toutes les actions précédemment énoncées :
  - vérifier que le fichier existe et est bien un fichier `.myc`
  - compiler les sources avec `make all` et rediriger les sorties sur la sortie standard et d'erreur
  - vérifier que les sources ont bien été compilés et le notifier sinon
  - compiler avec notre compilateur `myc` le fichier donné en paramètre
  - compiler avec `gcc` les fichiers `.h` et `.c` qui ont été générés par notre compilateur `myc`
  - vérifier qu'il n'y a pas eu d'erreur

Vérifiez à la main les contenus des fichiers `.c` et `.h` et vous verrez le résultat.

Concrètement, il suffit d'utiliser la commande suivante et tout se fera automatiquement : `./compil <fichier.myc>`.

# Travail demandé

Le projet devra assurer :
  - l'analyse des noms : les variables (et fonctions) utilisées sont-elles déclarées
  - l'analyse des types : les opérations effectués sont-elles bien typées
  - la production de code à trois addresses

Le compilateur `myc` produit vise à couvrir quelques éléments clès de la compilation. Il comprend notamment:
  - un mécanisme de déclarations explicites de variables
  - des expressions arithmétiques arbitraire de type calculatrice
  - des lectures ou écritures mémoires via des affectations avec variable utilisateur
  - un mécanisme de typage comprenant notamment `int` et `float`
  - des lectures ou écritures mémoires via des pointeurs
  - définitions et appels de fonctions récursives
  - un mécanisme de déclaration et d'utilisation de typé structurés (`struct`)

# Travail effectué

Nous avons effectué différentes fonctionnalités du projet. Les voici :
  - un mécanisme de déclarations explicite de variables : **FONCTIONNEL**
  - des expressions arithmétiques arbitraire de type calculatrice : **FONCTIONNEL**
  - des lectures ou écritures mémoires via des affectations avec variable utilisateur : **FONCTIONNEL**
  - un mécanisme de typage comprenant notamment `int` et `float` : **FONCTIONNEL**
  - des lectures ou écritures mémoires via des pointeurs : **FONCTIONNEL**
  - les structures conditionnelles `if then else ou juste if` : : **FONCTIONNEL** (sauf gestion des variables locales aux blocks...)

De plus, nous avons porté notre attention concernant la qualité du rendu à savoir un code commenté et documenté.

# Delta entre la soutenance et le rendu

Entre la version de la soutenance et le rendu, nous avons rempli différents objectifs.

Tout d'abord nous avons terminé les pointeurs. Au tout départ nous pensions qu'il fallait interpréter la valeur d'un pointeur (concernant le déréférencement) cependant, il suffisait juste de le représenter et de faire en sorte qu'il compile. Ce qui fait que cela est beaucoup plus facile que ce que nous pensions.

Suite à vos conseils, nous avons attaqué la partie sur les `if then else` dans la mesure où il s'agit d'une partie très intéressante et plus technique que les précédentes de la compilation.
