Feature: Scorable can have Participants
  Tests the addition and removal of Participants to and from a Scorable

  Background: Participants come from another domain
    Given the following participants are known within this bounded context
      | handle        | participantId                        | name          | birthdate  |
      | PARTICIPANT_1 | 11111111-1111-1111-1111-111111111111 | Participant 1 | 2001-01-01 |
      | PARTICIPANT_2 | 22222222-2222-2222-2222-222222222222 | Participant 2 | 2002-02-02 |
      | PARTICIPANT_3 | 33333333-3333-3333-3333-333333333333 | Participant 3 | 2003-03-03 |


  Scenario: Add a single player
    Given user created a game with name "Test"
    When user adds player with handle "PARTICIPANT_1" to the game
    Then the game should have the following players
      | handle        |
      | PARTICIPANT_1 |


  Scenario: Add an already added player
    Given user created a game with name "Test"
    And user added the following players to the game
      | handle        |
      | PARTICIPANT_1 |
    # TODO: of exception gooien via command handler?
    When user adds player with handle "PARTICIPANT_1" to the game
    Then the game should have the following players
      | handle        |
      | PARTICIPANT_1 |


  Scenario: Remove a single player
    Given user created a game with name "Test"
    And user added the following players to the game
      | handle        |
      | PARTICIPANT_1 |
      | PARTICIPANT_2 |
    When user removes player with handle "PARTICIPANT_2" from the game
    Then the game should have the following players
      | handle        |
      | PARTICIPANT_1 |


  Scenario: Remove a player that wasn't added
    Given user created a game with name "Test"
    And user added the following players to the game
      | handle        |
      | PARTICIPANT_1 |
      | PARTICIPANT_2 |
    When user removes player with handle "PARTICIPANT_3" from the game
    # TODO: of een exception op de command handler?
    Then the game should have the following players
      | handle        |
      | PARTICIPANT_1 |
      | PARTICIPANT_2 |

