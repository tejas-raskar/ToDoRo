import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  //Delete a task by its Id
  static Future<bool> deleteById(String id) async {
    final url = 'https://radical-scarlet.cmd.outerbase.io/deleteById?id=$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    return response.statusCode == 200;
  }

  //Fetch Tasks w.r.t the current user
  static Future<List?> fetchTasks({bool forceRefresh = false}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final url =
        'https://radical-scarlet.cmd.outerbase.io/fetchAll?userid=$userId';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json["response"]["items"] as List;

      //Store the fetched tasks in the Hive Box
      var box = Hive.box('tasks');
      box.put('tasks', result);

      return result;
    } else if (forceRefresh) {
      var box = Hive.box('tasks');
      box.delete('tasks');
    } else {
      return null;
    }
  }

  //Mark a Task as Complete
  static Future<void> completeById(String id) async {
    final body = {"is_complete": "true"};
    final url = 'https://radical-scarlet.cmd.outerbase.io/completeById?id=$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

  }

  //Update data
  static Future<bool> updateData(String id, Map body) async {
    final url = 'https://radical-scarlet.cmd.outerbase.io/updateTask?id=$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  //Create a new record
  static Future<bool> createData(Map body) async {
    const url = 'https://radical-scarlet.cmd.outerbase.io/addTask';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}