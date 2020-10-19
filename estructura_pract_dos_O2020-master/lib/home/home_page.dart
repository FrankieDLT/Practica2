import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pract_dos/home/bloc/home_bloc.dart';
import 'package:pract_dos/home/home_body.dart';
import 'package:pract_dos/models/todo_reminder.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc _homeBloc;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _todoTextController = TextEditingController();
  TimeOfDay _horario;

  @override
  void dispose() {
    // cerrar bloc
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.cyan[200],
            Colors.purpleAccent[700],
          ],
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Recordatorios'),
        ),
        backgroundColor: Colors.transparent,
        body: BlocProvider(
          create: (context) {
            _homeBloc = HomeBloc();
            return _homeBloc;
          },
          child: BlocConsumer<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is NewReminderState) {//OnAddElementEvent
                Scaffold.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("Reminder agregado!"),
                    ),
                  );
              }
            },
            builder: (context, state) {
              if (state is HomeInitialState) {
                _homeBloc.add(OnLoadRemindersEvent()); //OnLoadRemindersEvent
              } 
              // DONE: add more states or bloc consumer instead if needed
              return HomeBody(
                homeState: state,
                homeBloc: _homeBloc,
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              builder: (context) => StatefulBuilder(
                // para refrescar la botton sheet en caso de ser necesario
                builder: (context, setModalState) =>
                    _bottomSheet(context, setModalState),
              ),
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
              ),
            ).then(
              (result) {
                if (result != null) {
                  // DONE: bloc add evento to add reminder to db
                  _homeBloc.add(OnAddElementEvent(todoReminder: result));
                  print("Lenght of database: ${_homeBloc.reminderBox.length}");
                  // DONE: add reminder to HomeBody list view
                }
              },
            );
          },
          label: Text("Agregar"),
          icon: Icon(Icons.add_circle),
        ),
      ),
    );
  }

  Widget _bottomSheet(BuildContext context, StateSetter setModalState) {
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.purpleAccent[700],
              Colors.cyan[200],
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Agrega recordatorio",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            TextField(
              controller: _todoTextController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.text_fields,
                  color: Colors.black,
                ),
                labelText: "Ingrese actividad",
                labelStyle: TextStyle(color: Colors.black87),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.timer),
                  onPressed: () {
                    _selectTime(context);
                    // refreshes modal bottom sheet with new hour value
                    setModalState(() {});
                  },
                ),
                Text(
                  _horario == null
                      ? "Seleccione horario"
                      : "${_horario.hour}:${_horario.minute}",
                ),
              ],
            ),
            SizedBox(
              height: 12,
            ),
            MaterialButton(
              child: Text("Guardar"),
              onPressed: () {
                Navigator.of(context).pop(
                  TodoRemainder(
                    todoDescription: "${_todoTextController.text}",
                    hour: "${_horario.format(context)}",
                  ),
                );
                _todoTextController.clear();
                _horario = null;
              },
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  _selectTime(BuildContext context) async {
    await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then(
      (time) {
        if (time != null) {
          _horario = time;
        }
      },
    );
  }
}