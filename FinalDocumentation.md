
# triv.io

## Summary of Project: 
Our app, triv.io is a generic Trivia App that allows users to play with their friends and create new categories or even add to existing ones. We hope to build an interface that gives a generic user experience for all kinds of categories in order to reach a wider audience. The app will allow users to send instances of the quiz game to their friends, and allows them to test their knowledge of the particular category.

## Triv.io Trello Board Link: 
https://trello.com/invite/b/uw1VUGxd/fdb6db55e8f6a15071acdb3c56b4b708/trivio-app-project

## Tasks completed since Sprint Planning 5 (03.11.21)

### Donald Lieu 

### Jessica Wu 
* Pushed build 4 to testfilght and collected user feedback
* Fixed UL with Donald

### Manprit Heer

### Roberto Lozano

### Jessica Ma 
* Retrieve list of categories from the database, fix game setup flow when opponent is selected from friend list: https://github.com/ECS189E/project-w21-triv-io/commit/bc354f33ea265924afdb665d2a6ca72fcd6a1941
* Add share sheet for universal link, remove game instance when game setup is cancelled: https://github.com/ECS189E/project-w21-triv-io/commit/a55022557b2614eb4c7aebcea8f820ce13c594d4

## Overall contributions to app

### Donald Lieu 
* Helped connect project to database
* Created model classes/protocols to map to database
* Implemented leaderboard
* Implemented question/category submission
* Completed UL/ worked out bugs

### Jessica Wu 
* Wireframing
* UI design and implementation
* Made custom popup class
* Implemented game logic (bot for MVP and multi-player for final project)
* Connected db to game logic (update/query game instance when appropriate)
* Implemented spinningWheelViewController and questionViewController
* Implemented user profile page
* Implemented logic part of the table view on homepage (what to show the user upon clicking on each cell), along with a pending message view page
* Pushed to testflight and fixed small bugs based on user feedback
* Helped setup APN/Apple identifiers for notification, login with Apple, Universal link features and helped testing

### Manprit Heer

### Roberto Lozano
* Had been working on getting Push Notifications working through Apple's APN system however ran into troubles especially with debugging given a developer account is needed for running on physical device
* Was also working on setting up cloud messaging through Firebase to send remote notification based off of database triggers.

### Jessica Ma 
* Category selection – CategorySelectionViewController (each player must select 3 categories of questions to be added to the game)
* Displaying the user's games on their home screen – HomeViewController
    * Table view UI
    * Retrieving the player data that is displayed inside each cell
* Friend system:
    * Displaying the user's list of friends – FriendListViewController, OpponentSelectionViewController
    * Sending friend requests to other users
    * Receiving and accepting/declining friend requests
    * Update to game logic that allows a user to start a game with a player on their friend list
