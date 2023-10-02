import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/services/TaskService.dart';
import 'package:todo/utils/snackbars.dart';

class AddToDo extends StatefulWidget {
  final Map? todo;
  const AddToDo({
    super.key,
    this.todo,
  });

  @override
  State<AddToDo> createState() => _AddToDoState();
}

class _AddToDoState extends State<AddToDo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final title = todo?['title'];
      final description = todo?['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
  }


  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String getPriorityTag(DateTime dueDate) {
    final currentDay = DateTime.now();
    final days = dueDate.difference(currentDay).inDays;

    if (days <= 3) {
      return 'Urgent';
    } else if (days <= 7) {
      return 'Upcoming';
    } else {
      return 'Leisure';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(isEdit ? "Edit Task" : "Add ToDo"),
      // ),
      body: CustomScrollView(
        slivers: [
          //app Bar
          SliverAppBar.large(
            title: Text(
              isEdit ? "Edit Task" : "Add Task",
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: titleController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.flag_rounded),
                      label: const Text('Task'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextField(
                    minLines: 1,
                    maxLines: 4,
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.description_rounded),
                      label: Text('Description'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextField(
                    readOnly: true,
                    controller: dateController,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Due Date',
                        icon: IconButton(
                          onPressed: () async {
                            await _selectDate(context);
                            dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
                          },
                          icon: const Icon(Icons.calendar_today_rounded),
                        )),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  FilledButton(
                      // onPressed: isEdit ? updateData : uploadData,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if(isEdit) {
                        updateData();
                      }else {
                        uploadData();
                      }
                    },
                      child: Text(
                        isEdit ? "Edit" : 'Submit',
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print('You can not call update without todo data');
      return;
    }
    final id = todo['id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final dueDate = selectedDate.toIso8601String();
    final body = {
      "title": title,
      "description": description,
      "due_date": dueDate,
    };
    final isSuccess = await TaskService.updateData(id, body);

    if (isSuccess) {
      showSuccessFeedback(context, message: 'Updation Success');
    } else {
      showErrorFeedback(context, message: 'Updation failed');
    }
  }

  Future<void> uploadData() async {
    //Get the Data
    final title = titleController.text;
    final description = descriptionController.text;
    final dueDate = selectedDate.toIso8601String();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final priority = getPriorityTag(selectedDate);
    final body = {
      "title": title,
      "description": description,
      "is_complete": false,
      "due_date": dueDate,
      "user_id": userId,
      "priority": priority
    };

    //Upload the Data
    final isSuccess = await TaskService.createData(body);
    //Feedback to User
    if (isSuccess) {
      titleController.text = "";
      descriptionController.text = "";
      showSuccessFeedback(context, message: 'Creation Success');

    } else {
      showErrorFeedback(context, message: 'Creation failed');
    }
  }
}
