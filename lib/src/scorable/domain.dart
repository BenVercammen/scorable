
import 'package:jaguar_cqrs/definition.dart';

import 'commands.pb.dart';
import 'events.pb.dart';
import 'identifiers.pb.dart';

abstract class Scorable implements AggregateModel {

  static String AGGREGATE_NAME = 'Scorable';

  ScorableId scorableId;

  String name;

  List<Participant> _participants = List.empty(growable: true);

  Scorable();

  Scorable.forIdAndName(ScorableId this.scorableId, String this.name);

  Scorable.command(CreateScorable command) {
    // TODO: validate command? Instead of doing anything here?
    // In Axon is dit de constructor he... eens proberen?
  }

  @override
  String get id => scorableId.uuid;

  void scorableCreated(ScorableCreated event) {
    this.scorableId = event.scorableId;
    this.name = event.scorableName;
  }

  void addParticipant(AddParticipantToScorable command) {
    // TODO: factory method om juiste instance te maken obv command!
    Participant participant = new Individual(command.participantId, command.participantName);
    if (_participants.contains(participant)) {
      // TODO: geen exception gooien maar event sturen? Of specifieker event sturen...
      throw new Exception("Scorable already contains participant");
    }
    ParticipantAddedToScorable event = new ParticipantAddedToScorable();
    ParticipantId id = ParticipantId();
    id.uuid = command.participantId.uuid;
    event.participantId = id;
    event.participantName = command.participantName;
    // TODO: apply(event); ipv rechtstreeks op te roepen...
    participantAdded(event);
  }

  // TODO: en moet die niet "protected" zijn???
  void participantAdded(ParticipantAddedToScorable event) {
    // TODO: factory method om juiste instance te maken obv command!
    Participant participant = new Individual(event.participantId, event.participantName);
    // TODO: moet ik hier ook nog nagaan of dat event nog uitgevoerd mag worden?
    //  als participant er al bij staat, gewoon negeren zekers? of een "error event" sturen?
    //  op die manier hebben we nog wel ergens een "log" van potentiële problemen...
    //  ipv errors throwen (in event handling toch al niet zo'n goed idee zekers?) error events uitsturen
    _participants.add(participant);
  }

  void removeParticipant(RemoveParticipantFromScorable command) {
    ParticipantRemovedFromScorable event = new ParticipantRemovedFromScorable();
    event.participantId = command.participantId;
    // TODO: apply(event); ipv rechtstreeks op te roepen...
    participantRemoved(event);
  }

  void participantRemoved(ParticipantRemovedFromScorable event) {
    // TODO: factory method om juiste instance te maken obv command!
    Participant toRemove;
    _participants.forEach((participant) {
      if (event.participantId == participant.participantId) {
        toRemove = participant;
        return;
      }
    });
    _participants.remove(toRemove);
  }

  List<Participant> get participants {
    return List<Participant>.from(_participants);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Scorable &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              _participants == other._participants;

  @override
  int get hashCode => name.hashCode ^ _participants.hashCode;

}

///
/// The base Participant class
///
abstract class Participant {

  ParticipantId participantId;

  String name;

  Participant(this.participantId, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Participant &&
              runtimeType == other.runtimeType &&
              participantId == other.participantId &&
              name == other.name;

  @override
  int get hashCode => participantId.hashCode ^ name.hashCode;
}

class Individual extends Participant {
  DateTime birthdate;

  Individual(ParticipantId participantId, String name, [this.birthdate]) : super(participantId, name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          super == other &&
              other is Individual &&
              runtimeType == other.runtimeType &&
              birthdate == other.birthdate;

  @override
  int get hashCode => super.hashCode ^ birthdate.hashCode;
}

class Team extends Participant {
  List<Individual> individuals;

  Team(ParticipantId participantId, String name) : super(participantId, name) {
    individuals = List.empty(growable: true);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          super == other &&
              other is Team &&
              runtimeType == other.runtimeType &&
              individuals == other.individuals;

  @override
  int get hashCode => super.hashCode ^ individuals.hashCode;
}
