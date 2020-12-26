import 'dart:collection';

import 'package:uuid/uuid.dart';

import 'domain.dart';
import 'identifiers.pb.dart';

///
/// Contains Value Objects based on entities from outside the Scorable bounded context
///

///
/// User: ha, is al geen VO meer, eerder een read-only, "event listener" type entity...
/// we willen in de Scorable bounded context op elk moment weten of de user
/// die een command uitstuurt al dan niet voldoende rechten heeft om iets te doen!
///  => NEEN, da's "application logic", geen business "logic", dus hier niet van tel...
///
class User {
  Uuid userId;
  String username;

  Map<ScorableId, List<Permission>> permissions;

}

enum Permission {
  READ,
  WRITE
}




abstract class ParticipantRepository {

  List<Participant> getParticipants();

  void addParticipant(Participant participant);

  void removeParticipant(Participant participant);

  void addAll(List<Participant> participants);

}

class ParticipantRepositoryInMemoryImpl extends ParticipantRepository {

  Map<ParticipantId, Participant> _participants = new HashMap();

  @override
  void addParticipant(Participant participant) {
    _participants.putIfAbsent(participant.participantId, () => participant);
  }

  @override
  List<Participant> getParticipants() {
    return _participants.values;
  }

  @override
  void removeParticipant(Participant participant) {
    _participants.removeWhere((key, value) => key == participant.participantId);
  }

  @override
  void addAll(List<Participant> participants) {
    participants.forEach((participant) {
      addParticipant(participant);
    });
  }

}