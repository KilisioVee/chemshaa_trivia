# chemshaa_app
````
    ChemShaa is a Flutter-based live trivia application that delivers a mobile game-show experience. Players join a hosted trivia session, answer timed multiple-choice questions, receive immediate answer feedback, and compete for a cash prize.
    The app is designed around an automatic live-game flow: questions, answer reveals, host intermissions, and next-question loading screens progress without requiring users to tap a Continue button.
````
 ## Features
````
    Timed multiple-choice trivia questions
    Randomized question order for each session
    Circular countdown timer with seconds remaining
    Immediate answer feedback
    Correct selection: correct choice is highlighted in green
    Wrong selection: selected choice is highlighted in red and the correct choice in green
    No answer before timeout: the correct choice is highlighted in green
    Automatic game progression after answer feedback
    Full-screen host-speaking intermission
    Full-screen next-question loading experience
    Live-game metadata, including viewer count, question progress, and cash prize
    Player-state feedback for active, eliminated, correct, incorrect, and unanswered states
    End-of-game completion screen
````

### Build Laucher Icons

```
flutter pub run flutter_launcher_icons:main
```

### Build splash screen images

```
dart run flutter_native_splash:create
```
