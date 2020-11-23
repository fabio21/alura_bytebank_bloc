import 'package:bytebank/components/container.dart';
import 'package:bytebank/components/progress.dart';
import 'package:bytebank/database/dao/contact_dao.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/state_widget.dart';
import 'package:bytebank/screens/contact_form.dart';
import 'package:bytebank/screens/transaction_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsListCubit extends Cubit<WidgetStateCreate> {
  ContactsListCubit() : super(InitWidgetState());

  void reload(ContactDao dao) {
    emit(LoadingWidgetState());
    dao.findAll().then(
          (contacts) => emit(LoadedWidgetState(contacts)))
        .catchError(onError);
  }
}

class ContactsListContainer extends BlocContainer {
  final ContactDao dao = ContactDao();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactsListCubit>(
      create: (context) {
        final cubit = ContactsListCubit();
        cubit.reload(dao);
        return cubit;
      },
      child: ContactsListView(dao: dao),
    );
  }
}

class ContactsListView extends BlocContainer {
  final ContactDao dao;

  ContactsListView({this.dao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      body: BlocBuilder<ContactsListCubit, WidgetStateCreate>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case InitWidgetState:
              break;
            case LoadingWidgetState:
              return Progress();
              break;
            case LoadedWidgetState:
              final contacts = (state as LoadedWidgetState).contacts;
              return buildListView(contacts);
              break;
          }
          return Text('Unknown error');
        },
      ),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  ListView buildListView(List<Contact> contacts) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final Contact contact = contacts[index];
        return _ContactItem(contact,
            onClick: () => push(context, TransactionFormContainer(contact)));
      },
      itemCount: contacts.length,
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ContactForm(),
          ),
        );
        update(context);
      },
      child: Icon(
        Icons.add,
      ),
    );
  }

  void update(BuildContext context) =>
      context.read<ContactsListCubit>().reload(dao);
}

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final Function onClick;

  _ContactItem(
    this.contact, {
    @required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick(),
        title: Text(
          contact.name,
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
        subtitle: Text(
          contact.accountNumber.toString(),
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
