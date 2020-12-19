import 'package:csv/csv.dart';

import 'package:http/http.dart' as http;

Future<List<List<dynamic>>> getSheet(String key, String sheetName) => http
        .get(
            'https://docs.google.com/spreadsheets/d/${key}/gviz/tq?tqx=out:csv&sheet=${sheetName}')
        .then((value) {
      CsvToListConverter converter = CsvToListConverter(eol: '\n');
      return converter.convert(value.body);
    });
