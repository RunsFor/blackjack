# blackjack
CLI + backend implementation of blackjack game with classic rules

## Setup

To install gems:

```
bundle install
```

To run web server:

```
rackup
```

To run CLI:

```
ruby lib/cli.rb --host=localhost --port=9292 # Defaults: localhost, 9292
```

## Response example

When game in progress:

```
{
     "player" => [ ],
     "total_amount" => 1000, # Money available for the player
        "completed" => false, # Current status of the game
    "player_points" => [
        [0] 17
    ],
     "player_cards" => [
        [0] [
            [0] "7_of_spades",
            [1] "jack_of_spades"
        ]
    ],
    "dealer_points" => 11,
     "dealer_cards" => [
        [0] "ace_of_diamonds",
        [1] "***"
    ]
}
```

When player won the game:

```
{
    "player" => [
        [0] "win" # Round result
    ],
     "total_amount" => 850,
        "completed" => true,
    "player_points" => [
        [0] 18
    ],
     "player_cards" => [
        [0] [
            [0] "king_of_spades",
            [1] "8_of_diamonds"
        ]
    ],
    "dealer_points" => 17,
     "dealer_cards" => [
        [0] "8_of_hearts",
        [1] "2_of_clubs",
        [2] "7_of_clubs"
    ]
}
```
