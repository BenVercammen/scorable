import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:ogurets/ogurets.dart';
import 'package:score_io/score_io.dart';
import 'package:score_io/src/scorable/commands.pb.dart';
import 'package:score_io/src/scorable/domain.dart';
import 'package:score_io/src/scorable/events.pb.dart';
import 'package:score_io/src/scorable/identifiers.pb.dart';
import 'package:uuid/uuid.dart';

/// A basic Scorable implementation
class Game extends Scorable {

  Game(ScorableId scorableId, String name) : super() {
    this.scorableId = scorableId;
    this.name = name;
  }

  @override
  ScorableId get aggregateId => scorableId;

}

class ScorableStepDefinitions {

  Map<String, Participant> _knownParticipants = new HashMap();

  Scorable game;

  @Given(r'user created a game with name {string}')
  void aGameWithName(String name) async {
    game = Game(ScorableId(), name);
  }

  @Given(r'user added the following players to the game')
  void userAddedTheFollowingParticipants({GherkinTable table}) async {
    assert(game != null);
    Map<String, Individual> participants = parseIndividuals(table);
    participants.keys.forEach((handle) {
      ParticipantAddedToScorable event = new ParticipantAddedToScorable();
      Participant participant = _knownParticipants[handle];
      event.participantId = participant.participantId;
      event.participantName ??= participant.name;
      game.participantAdded(event);
    });
  }

  @When(r'user adds player with handle {string} to the game')
  void individualWithNameIsAddedToTheGame(String handle) async {
    assert(game != null);
    AddParticipantToScorable command = new AddParticipantToScorable();
    Participant participant = _knownParticipants[handle];
    command.participantId = participant.participantId;
    command.participantName = participant.name;
    game.addParticipant(command);
  }

  @When(r'user removes player with handle {string} from the game')
  void individualWithNameIsRemovedFromTheGame(String handle) async {
    assert(game != null);
    var participant = _knownParticipants[handle];
    assert(participant != null);
    RemoveParticipantFromScorable command = new RemoveParticipantFromScorable();
    command.participantId = participant.participantId;
    game.removeParticipant(command);
  }

  @Then(r'the game should have the following players')
  void theGameShouldHaveTheFollowingParticipants({GherkinTable table}) async {
    List<String> expectedHandles = parseIndividuals(table).keys.toList();
    List<String> actualHandles = new List.empty(growable: true);
    for (Participant gameParticipant in game.participants) {
      for (String handle in _knownParticipants.keys) {
        if (gameParticipant.participantId == _knownParticipants[handle].participantId) {
          actualHandles.add(handle);
        }
      }
    }
    assert(DeepCollectionEquality().equals(expectedHandles, actualHandles));
  }

  /// Individuals (met hun handles) uit de table parsen
  Map<String, Individual> parseIndividuals(GherkinTable table) {
    Map<String, int> headerIndexes = _getHeaderIndexMap(table);
    Map<String, Individual> participants = new HashMap();
    table.gherkinRows().getRange(1, table.gherkinRows().length).map((element) {
      var split = element.trim().split('|');
      var handle = _getTableValue(headerIndexes, split, 'handle');
      handle ??= new Uuid().toString();
      var id = _getTableValue(headerIndexes, split, 'participantId');
      ParticipantId participantId = new ParticipantId();
      if (null != id) {
        participantId.uuid = id;
      }
      var name = _getTableValue(headerIndexes, split, 'name');
      String birthdateString = _getTableValue(headerIndexes, split, 'birthdate');
      DateTime birthdate = (null == birthdateString) ? null : DateTime.parse(birthdateString);
      Participant participant = Individual(participantId, name, birthdate);
      participants.putIfAbsent(handle, () => participant);
    }).toList();
    return participants;
  }

  String _getTableValue(Map<String, int> headerIndexes, List<String> split, String key) {
    return headerIndexes.containsKey(key) && headerIndexes[key] >= 0 ? split[headerIndexes[key]].trim() : null;
  }

  Map<String, int> _getHeaderIndexMap(GherkinTable table) {
    List<String> headers = table.gherkinRows()[0].split('|');
    Map<String, int> headerMap = new HashMap();
    int index = 0;
    headers.forEach((header) {
      headerMap.putIfAbsent(header.trim(), () => index++);
    });
    return headerMap;
  }

  @Given(r'the following participants are known within this bounded context')
  void participantRepositoryContainsFollowingParticipants({GherkinTable table}) async {
    Map<String, Individual> participants = parseIndividuals(table);
    _knownParticipants.addAll(participants);
  }

}
