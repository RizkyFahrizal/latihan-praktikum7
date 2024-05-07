import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    // Creates a Provider widget
    create: (context) =>
        UniversityProvider(), // Creates a UniversityProvider instance
    child: MyApp(), // Child widget to be wrapped with Provider
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Data Universitas Negara ASEAN'),
        ),
        body: UniversityList(),
      ),
    );
  }
}

class UniversityProvider extends ChangeNotifier {
  List<dynamic> universities = [];
  String selectedCountry =
      'Indonesia'; // Initialize selected country to Indonesia

  Future<void> fetchUniversities() async {
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$selectedCountry'));

    if (response.statusCode == 200) {
      universities = json.decode(response.body);
      notifyListeners(); // Notify listeners about data change
    }
  }

  void changeCountry(String newCountry) {
    selectedCountry = newCountry;
    fetchUniversities();
  }
}

class UniversityList extends StatefulWidget {
  @override
  _UniversityListState createState() => _UniversityListState();
}

class _UniversityListState extends State<UniversityList> {
  @override
  void initState() {
    super.initState();
    Provider.of<UniversityProvider>(context, listen: false).fetchUniversities();
  }

  @override
  Widget build(BuildContext context) {
    final universityProvider = Provider.of<UniversityProvider>(context);

    return Column(
      children: [
        // Combo box to select country
        DropdownButton<String>(
          value: universityProvider.selectedCountry,
          items: [
            DropdownMenuItem<String>(
              value: 'Indonesia',
              child: Text('Indonesia'),
            ),
            DropdownMenuItem<String>(
              value: 'Malaysia',
              child: Text('Malaysia'),
            ),
            DropdownMenuItem<String>(
              value: 'Viet Nam',
              child: Text('Vietnam'),
            ),
            DropdownMenuItem<String>(
              value: "Lao People's Democratic Republic",
              child: Text('Laos'),
            ),
            DropdownMenuItem<String>(
              value: 'Philippines',
              child: Text('Filipina'),
            ),
            DropdownMenuItem<String>(
              value: 'Myanmar',
              child: Text('Myanmar'),
            ),
            DropdownMenuItem<String>(
              value: 'Thailand',
              child: Text('Thailand'),
            ),
            DropdownMenuItem<String>(
              value: 'Cambodia',
              child: Text('Kamboja'),
            ),
            DropdownMenuItem<String>(
              value: 'Brunei Darussalam',
              child: Text('Brunei Darussalam'),
            ),
            DropdownMenuItem<String>(
              value: 'Singapore',
              child: Text('Singapura'),
            ),
          ],
          onChanged: (value) {
            universityProvider.changeCountry(value!);
          },
        ),

        // List of universities
        Expanded(
          child: ListView.builder(
            itemCount: universityProvider.universities.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(universityProvider.universities[index]['name']),
                subtitle: Text(
                    universityProvider.universities[index]['web_pages'][0]),
              );
            },
          ),
        ),
      ],
    );
  }
}
