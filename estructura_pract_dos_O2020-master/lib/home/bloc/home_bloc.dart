import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:pract_dos/models/todo_reminder.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  //Referencia a Box previamiente abierta en Main
  Box reminderBox = Hive.box("ReminderList");
  HomeBloc() : super(HomeInitialState());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is OnLoadRemindersEvent) {
      try {
        List<TodoRemainder> _existingReminders = _loadReminders();
        yield LoadedRemindersState(todosList: _existingReminders);
      } on DatabaseDoesNotExist catch (_) {
        yield NoRemindersState();
      } on EmptyDatabase catch (_) {
        yield NoRemindersState();
      }
    }
    if (event is OnAddElementEvent) {
      _saveTodoReminder(event.todoReminder);
      yield NewReminderState(todo: event.todoReminder);
    }
    if (event is OnReminderAddedEvent) {
      yield AwaitingEventsState();
    }
    if (event is OnRemoveElementEvent) {
      _removeTodoReminder(event.removedAtIndex);
    }
  }

  List<TodoRemainder> _loadReminders() {
    // ver si existen datos To-doRemainder en la box y sacarlos como Lista (no es necesario hacer get ni put)
    // debe haber un adapter para que la BD pueda detectar el objeto
    if(reminderBox.length>0) {//Existen Datos?
    // (1)      (2)        (3)  (4)     (5)                        (6)                (7)
      return reminderBox.values.map((objectinlist) => objectinlist as TodoRemainder).toList();
    }
  /**
   * 1) Regresa
   * 2) De la base de datos
   * 3) Todos los valores
   * 4) A partir de su mapa
   * 5) Cada elemento de la BD
   * 6) Con un Cast de objeto tipo TodoRemainder
   * 7) Y lo convierte en una lista (Expected return type)
   */
  
    throw EmptyDatabase();
  }

  void _saveTodoReminder(TodoRemainder todoReminder) {
    // DONE:add item here
    reminderBox.add(todoReminder);
  }

  void _removeTodoReminder(int removedAtIndex) {
    // DONE:delete item here
    reminderBox.deleteAt(removedAtIndex);
  }
}

class DatabaseDoesNotExist implements Exception {
 /*  if(reminderBox == null)
  print("No database to use"); */
}

class EmptyDatabase implements Exception {
   /* if(reminderBox.lenght == 0)
  print("No database to use"); */
}
