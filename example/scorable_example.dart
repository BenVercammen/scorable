import 'package:score_io/score_io.dart';
import 'package:score_io/src/scorable/identifiers.pb.dart';
import 'package:uuid/uuid.dart';

/// List of Participants that are known within this domain.
/// These Participants come from outside our bounded context.
List<Participant> _knownParticipants = [
  Individual(ParticipantId(), "Player 1"),
  Individual(ParticipantId(), "Player 2"),
  Individual(ParticipantId(), "Player 3")
];

/// The Scorable subclass used in this example
class Game extends Scorable {

  Game(CreateScorable createScorable) : super.command(createScorable);

  @override
  ScorableId get aggregateId => scorableId;

}

/// Make sure all "external entities" have an actual UUID value
void _setUuids() {
  _knownParticipants.forEach((participant) {
    participant.participantId.uuid = Uuid().v4();
  });
}

/// Simple example of how to use the Scorable commands.
/// We are using CQRS, so all changes are being applied using commands and events.
void main() {
  // Set UUID's for known entities...
  _setUuids();
  // Create the Scorable instance
  CreateScorable createScorable = CreateScorable();
  createScorable.scorableId = ScorableId();
  createScorable.scorableId.uuid = Uuid().v4();
  createScorable.name = 'Test Game';
  Game game = Game(createScorable);
  // Add all known Participants to the Scorable
  _knownParticipants.forEach((participant) {
    AddParticipantToScorable addCommand = new AddParticipantToScorable();
    addCommand.participantId = participant.participantId;
    addCommand.participantName = participant.name;
    game.addParticipant(addCommand);
  });
  // Remove a single Participant from the Scorable
  RemoveParticipantFromScorable removeCommand = new RemoveParticipantFromScorable();
  removeCommand.participantId = _knownParticipants[1].participantId;
  game.removeParticipant(removeCommand);
  // We should have only 2 participants now...
  print(game.participants.length);
}
