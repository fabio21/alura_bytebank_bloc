import 'dart:async';

import 'package:bytebank/components/container.dart';
import 'package:bytebank/components/progress.dart';
import 'package:bytebank/components/response_dialog.dart';
import 'package:bytebank/components/transaction_auth_dialog.dart';
import 'package:bytebank/http/webclients/transaction_webclient.dart';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/state_widget.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class TransactionFormCubit extends Cubit<WidgetStateCreate> {
  TransactionFormCubit() : super(InitWidgetState());

  void save(
      Transaction transaction, String password, BuildContext context) async {
    emit(LoadingWidgetState());
    await _send(transaction, password, context);
  }

  Future<Transaction> _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    await TransactionWebClient()
        .save(transactionCreated, password)
        .then((transaction) => emit(LoadedWidgetState(transaction)))
        .catchError((e) {
      emit(FatalErrorWidgetState(e.message));
    }, test: (e) => e is HttpException).catchError((e) {
      emit(FatalErrorWidgetState('timeout submitting the transaction'));
    }, test: (e) => e is TimeoutException).catchError(
      (e) {
        emit(FatalErrorWidgetState(e.message));
      },
    );
  }
}

class TransactionFormContainer extends BlocContainer {
  final Contact _contact;

  TransactionFormContainer(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionFormCubit>(
      create: (context) {
        return TransactionFormCubit();
      },
      child: TransactionForm(_contact),
      // child: BlocListener<TransactionFormCubit, WidgetStateCreate>(
      //   listener: (context, state) {
      //     if (state is FinishWidgetState) {
      //       Navigator.pop(context);
      //     }
      //   },
      //   child: TransactionForm(_contact),
      // ),
    );
  }
}

class TransactionForm extends StatelessWidget {
  final Contact contact;

  TransactionForm(this.contact);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: BlocBuilder<TransactionFormCubit, WidgetStateCreate>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case InitWidgetState:
              return BasicForm(contact: contact);
              break;
            case LoadingWidgetState:
              return Progress(message: 'Sending...');
              break;
             case LoadedWidgetState:
              return SuccessDialog("OK");
            case FatalErrorWidgetState:
              final message = (state as FatalErrorWidgetState).message;
              return FailureDialog(message);
            default:
              return FailureDialog('Unknown error');
          }
        },
      ),
    );
  }

  Future _showSuccessfulMessage(
      Transaction transaction, BuildContext context) async {
    if (transaction != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SuccessDialog('successful transaction');
          });
      Navigator.pop(context);
    }
  }

  void _showFailureMessage(
    BuildContext context, {
    String message = 'Unknown error',
  }) {
    showDialog(
        context: context,
        builder: (contextDialog) {
          return FailureDialog(message);
        });
  }
}

class BasicForm extends StatelessWidget {
  final Contact contact;
  final TextEditingController _valueController = TextEditingController();

  final String transactionId = Uuid().v4();

  BasicForm({Key key, this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: RaisedButton(
                    child: Text('Transfer'),
                    onPressed: () => onPressed(context),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onPressed(BuildContext context) {
    final double value = double.tryParse(_valueController.text);
    final transactionCreated = Transaction(
      transactionId,
      value,
      contact,
    );
    buildShowDialog(context, transactionCreated);
  }

  Future buildShowDialog(BuildContext context, Transaction transactionCreated) {
    return showDialog(
      context: context,
      builder: (contextDialog) {
        return TransactionAuthDialog(
          onConfirm: (String password) {
            BlocProvider.of<TransactionFormCubit>(context)
                .save(transactionCreated, password, context);
          },
        );
      },
    );
  }
}

class ErrorForm extends StatelessWidget {
  final String message;

  const ErrorForm({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Message error"),
      ),
      body: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
    );
  }
}
