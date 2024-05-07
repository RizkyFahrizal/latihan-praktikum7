import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(BlocProvider(
    create: (context) => UniversityCubit()..fetchUniversities(),
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

class UniversityCubit extends Cubit<List<dynamic>> {
  UniversityCubit() : super([]);

  String selectedCountry = 'Indonesia'; // Initialize selected country

  Future<void> fetchUniversities() async {
    final response = await http.get(Uri.parse(
      'http://universities.hipolabs.com/search?country=$selectedCountry',
    ));

    if (response.statusCode == 200) {
      final universities = json.decode(response.body);
      emit(universities); // Emit new state
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
    final universityCubit = BlocProvider.of<UniversityCubit>(context);

    return BlocBuilder<UniversityCubit, List<dynamic>>(
      bloc: universityCubit,
      builder: (context, universities) {
        return Column(
          children: [
            // Combo box to select country
            DropdownButton<String>(
              value: universityCubit.selectedCountry,
              items: aseanCountries.map((country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (value) {
                universityCubit.changeCountry(value!);
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
