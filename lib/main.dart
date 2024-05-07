import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(BlocProvider(
    create: (context) => UniversityBloc()..add(FetchUniversities()),
    child: MyApp(),
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

class UniversityBloc extends Bloc<UniversityEvent, List<dynamic>> {
  UniversityBloc() : super([]);

  String selectedCountry = 'Indonesia'; // Initialize selected country

  @override
  Stream<List<dynamic>> mapEventToState(UniversityEvent event) async* {
    if (event is FetchUniversities) {
      yield await fetchUniversities();
    } else if (event is ChangeCountry) {
      selectedCountry = event.newCountry;
      yield await fetchUniversities();
    }
  }

  Future<List<dynamic>> fetchUniversities() async {
    final response = await http.get(Uri.parse(
      'http://universities.hipolabs.com/search?country=$selectedCountry',
    ));

    if (response.statusCode == 200) {
      final universities = json.decode(response.body);
      return universities;
    } else {
      return [];
    }
  }
}

abstract class UniversityEvent {}

class FetchUniversities extends UniversityEvent {}

class ChangeCountry extends UniversityEvent {
  final String newCountry;

  ChangeCountry(this.newCountry);
}

class UniversityList extends StatefulWidget {
  @override
  _UniversityListState createState() => _UniversityListState();
}

class _UniversityListState extends State<UniversityList> {
  final List<String> aseanCountries = [
    'Indonesia',
    'Malaysia',
    'Vietnam',
    "Lao People's Democratic Republic",
    'Philippines',
    'Myanmar',
    'Thailand',
    'Cambodia',
    'Brunei Darussalam',
    'Singapore',
  ];

  @override
  Widget build(BuildContext context) {
    final universityBloc = BlocProvider.of<UniversityBloc>(context);

    return BlocBuilder<UniversityBloc, List<dynamic>>(
      bloc: universityBloc,
      builder: (context, universities) {
        return Column(
          children: [
            // Combo box to select country
            DropdownButton<String>(
              value: universityBloc.selectedCountry,
              items: aseanCountries.map((country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                universityBloc.add(ChangeCountry(value!));
              },
            ),

            // List of universities
            Expanded(
              child: ListView.builder(
                itemCount: universities.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(universities[index]['name']),
                    subtitle: Text(universities[index]['web_pages'][0]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
