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
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //méthode automatiquement appelée dès que les conditions du widget changent
    var appState = context.watch<
        MyAppState>(); //la méthode watch permet à MyHoePage de suivre les modif de l'état actuel de l'application
    var pairWords = appState.current;

    return Scaffold(
      //scaffold = échafaudage --chaque méthode build doit renvoyer un widget/une arborescence de widget
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          //l'un des principaux widget de mise en page. accepte un nb illimité d'enfants et les place dans une colonne de haut en bas
          children: [
            Text('GOGOGOGOGO'),
            //pour faire apparaître du texte
            BigCard(pairWords: pairWords),
            SizedBox(height: 10),
            ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Clic'))
          ],
        ),
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