import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MyApp()); //indique à Flutter qu'il faut exécuter la fonction qui se trouve dans MyApp
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'FIRST FLUTTER APPLICATION',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  //cette classe définie les données dont l'appli à besoin, elle implémente ChangeNotifier pour informer les autres widgets de ses propres modifications
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners(); //méthode de changeNotifier qui garantit que toute personne surveillant cette classe est informée
  }
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    // Scaffold fournit la structure de base d'une page (appbar, body, drawer, etc.)
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          // Le corps de la page contient une rangée horizontale de widgets
          body: Row(
            children: [
              // SafeArea évite que le contenu soit masqué par des zones système (notch, barre d'état)
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600, //  étendu, barre étroite avec icônes seulement
                  destinations: [
                    // NavigationRailDestination représente une option dans la barre de navigation latérale
                    NavigationRailDestination(
                      icon: Icon(Icons.home), // Icône pour la destination "Home"
                      label: Text('Home'),     // Label texte qui s'affiche si extended = true
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,    // Index actuellement sélectionné dans la barre de navigation
                  onDestinationSelected: (value) {
                    // Callback appelé lorsque l'utilisateur sélectionne une destination
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              // Expanded prend tout l'espace horizontal restant dans la Row
              Expanded(
                child: Container(
                  // Couleur de fond provenant du thème actuel, zone principale de contenu
                  color: Theme.of(context).colorScheme.primaryContainer,
                  // Contenu principal affiché ici : l'affichage de la page générateur
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupère l'état partagé de l'application via un provider (context.watch)
    var appState = context.watch<MyAppState>();
    var pairWords = appState.current; // Prenez un élément courant à afficher

    IconData icon;
    // Choix de l'icône selon que l'élément est dans la liste des favoris ou non
    if (appState.favorites.contains(pairWords)) {
      icon = Icons.favorite; // Icône coeur rempli si favori
    } else {
      icon = Icons.favorite_border; // Coeur vide sinon
    }

    return Center(
      // Centre le contenu dans la zone disponible
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement les enfants
        children: [
          BigCard(pairWords: pairWords), // Widget personnalisé affichant l'élément pair
          SizedBox(height: 10), // Espace vertical entre les widgets
          Row(
            mainAxisSize: MainAxisSize.min, // Ligne avec taille minimale (autant que contenu)
            children: [
              ElevatedButton.icon(
                // Bouton avec icône et texte
                onPressed: () {
                  // Action au clic : bascule entre favori ou non
                  appState.toggleFavorite();
                },
                icon: Icon(icon), // Icone coeur (plein ou vide)
                label: Text('Like'), // Texte du bouton
              ),
              SizedBox(width: 10), // Espace horizontal entre boutons
              ElevatedButton(
                onPressed: () {
                  // Action au clic : passe à l'élément suivant
                  appState.getNext();
                },
                child: Text('Next'), // Texte du bouton
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pairWords,
  });

  final WordPair pairWords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //pour avoir le même thème que le contexte dans lequel est ajouté le widget (ici homePage)
    final style = theme.textTheme.displayMedium!.copyWith( //theme.textTheme accède au thème des polices
        color: theme.colorScheme.onPrimary, //acccède au thème des polices inclu dans le thème choisis précédemment
        decoration:  TextDecoration.overline,
        decorationColor: theme.colorScheme.onPrimary
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text(pairWords.asUpperCase, style: style,),
      ),
    );
  }
}
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}