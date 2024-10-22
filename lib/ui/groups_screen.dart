import 'package:flutter/material.dart';

import 'package:todo_list/models/group.dart';
import 'package:todo_list/objectbox.g.dart';

import 'package:todo_list/ui/add_groups_screen.dart';
import 'package:todo_list/ui/task_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groups = <Group>[]; // Lista vacía de grupos
  late final Store _store;
  late final Box<Group> _groupsBox;

  Future<void> _addGroup() async {
    final result = await showDialog(
      context: context,
      builder: (_) => const AddGroupScreen(),
    );

    if (result != null && result is Group) {
      _groupsBox.put(result);
      _loadGroups();
    }
  }

  void _loadGroups() {
    _groups.clear();
    setState(() {
      _groups.addAll(_groupsBox.getAll());
    });
  }

  Future<void> _loadStore() async {
    _store = await openStore();
    _groupsBox = _store.box<Group>();
    _loadGroups();
  }

  void _deleteGroup(Group group) {
    _groupsBox.remove(group.id); // Elimina el grupo de la base de datos
    _loadGroups(); // Recarga la lista de grupos
  }

  Future<void> _showOptionsDialog(Group group) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opciones de Grupo'),
          content: const Text('¿Qué te gustaría hacer con este grupo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                _goToTask(group); // Ir a la pantalla de tareas
              },
              child: const Text('Ver Tareas'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                _deleteGroup(group); // Eliminar el grupo
              },
              child: const Text('Eliminar Grupo'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo sin hacer nada
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _goToTask(Group group) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TasksScreen(group: group, store: _store),
      ),
    );
    _loadGroups();
  }

  @override
  void initState() {
    _loadStore();
    super.initState();
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO LIST'),
      ),
      body: _groups.isEmpty
          ? const Center(
              child: Text('There are no Groups'),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index]; // Accede al grupo
                return _GroupItem(
                  onTap: () => _showOptionsDialog(group), // Muestra opciones al hacer clic
                  group: group,
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Agregar Grupo'),
        onPressed: _addGroup,
      ),
    );
  }
}

class _GroupItem extends StatelessWidget {
  final VoidCallback onTap;
  final Group group;

  const _GroupItem({required this.onTap, required this.group});

  @override
  Widget build(BuildContext context) {
    final description =
        group.taskDescription(); // Obtiene la descripción de la tarea

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: onTap, // Muestra el diálogo de opciones al hacer clic
        child: Container(
          decoration: BoxDecoration(
            color: Color(group.color), // Color del grupo
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
