part of 'delete_account_bloc.dart';

abstract class DeleteAccountEvent {}

class DeleteAccountSubmitted extends DeleteAccountEvent {
  final String reason;
  final String confirmation;

  DeleteAccountSubmitted({
    required this.reason,
    required this.confirmation,
  });
}