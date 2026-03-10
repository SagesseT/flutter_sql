import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

Future getUsers() async {
  var url = Uri.parse("http://localhost/mon_api/get_users.php");
  var response = await http.get(url);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Erreur serveur");
  }
}

Future addUser(String nom, String email) async {
  var url = Uri.parse("http://localhost/mon_api/insert_user.php");

  var response = await http.post(
    url,
    body: {
      "nom": nom,
      "email": email,
    },
  );

  return jsonDecode(response.body);
}

TextEditingController nomController = TextEditingController();
TextEditingController emailController = TextEditingController();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter SQL'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Future users;

  @override
  void initState() {
    super.initState();
    users = getUsers();
  }

  void refreshUsers() {
    setState(() {
      users = getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter SQL"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 108, 180, 231),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            /// LISTE DES UTILISATEURS
            Expanded(
              child: FutureBuilder(
                future: users,
                builder: (context, snapshot) {

                  if (snapshot.hasData) {

                    var data = snapshot.data as List;

                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(data[index]['nom']),
                          subtitle: Text(data[index]['email']),
                        );
                      },
                    );

                  } else if (snapshot.hasError) {

                    return const Center(child: Text("Erreur"));

                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),

            const Divider(),

            /// FORMULAIRE
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: "Nom",
              ),
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {

                var result = await addUser(
                  nomController.text,
                  emailController.text,
                );

                if (result["success"]) {

                  nomController.clear();
                  emailController.clear();

                  refreshUsers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Utilisateur ajouté")),
                  );
                }
              },
              child: const Text("Ajouter utilisateur"),
            )

          ],
        ),
      ),
    );
  }
}