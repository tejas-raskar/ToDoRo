import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:todo/screens/addtodo.dart';
import 'package:todo/services/TaskService.dart';
import 'package:todo/utils/snackbars.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  bool isComplete = false;
  bool isChecked = false;

  String _printDuration(Duration duration) {
    if (duration.isNegative) {
      return '';
    } else if (duration.inHours < 24) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)} hrs left";
    } else if (duration.inDays <= 2) {
      return '${duration.inDays} day left';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage,
          icon: const Icon(Icons.add),
          label: const Text("Add Task")),
      // floatingActionButton: OpenContainer(
      //   transitionDuration: const Duration(milliseconds: 300),
      //   transitionType: ContainerTransitionType.fadeThrough,
      //   openBuilder: (context, voidCallback_) {
      //     return const AddToDo();
      //   },
      //   closedElevation: 6.0,
      //   closedShape: const RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(16))),
      //   closedColor: Theme.of(context).colorScheme.onSecondary,
      //   closedBuilder: (context, openContainer) {
      //     return const SizedBox(
      //       height: 56,
      //       width: 56,
      //       child: Center(
      //           child: Icon(
      //         Icons.add,
      //         size: 24,
      //       )),
      //     );
      //   },
      // ),
      body: RefreshIndicator(
        onRefresh: () => fetchData(forceRefresh: true),
        child: CustomScrollView(
          slivers: <Widget>[
            const SliverAppBar.large(
              centerTitle: true,
              title: Text(
                'Tasks',
                style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Ubuntu'),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (items.isEmpty) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.60,
                      height: MediaQuery.of(context).size.height * 0.60,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          "Create a New Task",
                          style: TextStyle(fontSize: 16, fontFamily: 'Ubuntu'),
                        )),
                      ),
                    );
                  } else {
                    final item = items[index] as Map;
                    final id = item['id'] as String;
                    final priority = (item['priority'] as String?) ?? 'default';
                    return GestureDetector(
                      onLongPressStart: (details) {
                        HapticFeedback.mediumImpact();
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Edit'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    navigateToEditPage(item);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text('Delete'),
                                  onTap: () async{
                                    Navigator.pop(context);
                                    await deleteById(id);
                                    fetchData(forceRefresh: true);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Stack(children: [
                        Column(
                          children: [
                            CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: item['is_complete'],
                                onChanged: (bool? value) {
                                  HapticFeedback.mediumImpact();
                                  setState(() {
                                    item['is_complete'] = value!;
                                    if (item['is_complete']) {
                                      Future.delayed(
                                          const Duration(milliseconds: 500),
                                          () {
                                        setState(() {
                                          items.removeAt(index);
                                        });
                                        TaskService.completeById(id);
                                        fetchData(forceRefresh: true);
                                      });
                                    }
                                  });
                                },
                                title: Text(
                                  item['title'],
                                  style: TextStyle(
                                      decoration: item['is_complete']
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Ubuntu'),
                                ),
                                subtitle: item['description'] != null &&
                                        item['description'].isNotEmpty
                                    ? Text(item['description'])
                                    : null,
                                secondary: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            color: getPriorityColor(priority),
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            priority,
                                            style: const TextStyle(
                                              color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                    Text(
                                      priority == 'Urgent'
                                          ? _printDuration(
                                              DateTime.parse(item['due_date'])
                                                  .difference(DateTime.now()))
                                          : "",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: getPriorityColor(priority)),
                                    )
                                  ],
                                )),
                            const Divider(),
                          ],
                        ),
                      ]),
                    );
                  }
                },
                childCount: items.isEmpty ? 1 : items.length,
              ),
            )
          ],
        ),
      ),
    ));
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgent':
        return Colors.red;
      case 'Upcoming':
        return Colors.yellow;
      case 'Leisure':
        return Colors.green;
      default:
        return Colors
            .grey; // Default color in case of unexpected priority value
    }
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddToDo(todo: item));
    await Navigator.push(context, route);
    fetchData(forceRefresh: true);
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => AddToDo());
    await Navigator.push(context, route);
    fetchData(forceRefresh: true);
  }

  Future<void> fetchData({bool forceRefresh = false}) async {
    var box = Hive.box('tasks');
    var cachedTasks = box.get('tasks');

    if (cachedTasks != null && !forceRefresh) {
      setState(() {
        items = cachedTasks;
      });
    } else {
      final response = await TaskService.fetchTasks(forceRefresh: forceRefresh);

      if (response != null) {
        setState(() {
          items = response;
        });
      }
    }
  }

  Future<void> deleteById(String id) async {
    final isSuccess = await TaskService.deleteById(id);
    if (isSuccess) {
      showSuccessFeedback(context, message: "Task deleted successfully");
      final filtered = items.where((element) => element['id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {}
  }
}
