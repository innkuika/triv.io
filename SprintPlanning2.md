# triv.io

## Summary of Project: 
Our app, triv.io is a generic Trivia App that allows users to play with their friends and create new categories or even add to existing ones. We hope to build an interface that gives a generic user experience for all kinds of categories in order to reach a wider audience. The app will allow users to send instances of the quiz game to their friends, and allows them to test their knowledge of the particular category.

## Triv.io Trello Board Link: 
https://trello.com/invite/b/uw1VUGxd/fdb6db55e8f6a15071acdb3c56b4b708/trivio-app-project

## Previous Tasks (02.10.21)

### Donald Lieu
* Research on making an instance of a game on iOS 
    * Created protocols for proposed database schema. 
    > https://github.com/ECS189E/project-w21-triv-io/commit/6c15e7497c4347b992e3afb40ccbcec3ca386a2b#diff-a2936beff2f4c0d0b8fc4047d78e060e0d09c0b2b2d26704fed69e635d4307a8
    * Created function stubs for classes implementing said protocols and some mocks. 
    > https://github.com/ECS189E/project-w21-triv-io/commit/8be6575b06c90d5a0820e9cc168d68c79bc8eeb1#diff-a2936beff2f4c0d0b8fc4047d78e060e0d09c0b2b2d26704fed69e635d4307a8
### Jessica Wu 
* Front-end Wireframing 
  * Used Figma for MVP wireframing. Discussed the wireframe with teammates and improved it based on feedback. See work at: https://www.figma.com/file/Ff3cBXe8WKmy5hnkCPfrZN/triv.io?node-id=0%3A1
### Manprit Heer
* Creation of Rough Schema for Firebase
	* Uploaded png file of schema: https://github.com/ECS189E/project-w21-triv-io/commit/9c4db5b0cd043c8b881c93872280a9481c7fa9b7
### Roberto Lozano
* Authentication Log-In System
	* Decided which platforms we would like to use for our Login/Authentication system.
	* Worked on researching and doing set up for the authentication and login system for our app. Setup FireStore/FireBase app and began implementing Google Authentication/Login.
	* Link to commit: https://github.com/ECS189E/project-w21-triv-io/commit/ef6f2f1ec282e348c528b8aea67367855ad7a250
### Jessica Ma
* Skeleton of app, push to Github
>Link of commit/Description of Work


## **Current Tasks** (02.17.21)

### Donald Lieu
* Page 2: UI: Create Game/Join Game Page
* Added navigation controller and button to navigate to new home controller.
> https://github.com/ECS189E/project-w21-triv-io/commit/cc4b292b2717e546054c9157fe4815dd5a0204dd#diff-a2936beff2f4c0d0b8fc4047d78e060e0d09c0b2b2d26704fed69e635d4307a8
### Jessica Wu 
* Page 3/3.5: UI: Single-Player/Bot Page + Spin Page
 * Did some research on existing libraries for fortune wheels and tried to implement one that meets the requirement of the app. Gathered some image assests that will be useful in later development.
 * Links to commit: https://github.com/ECS189E/project-w21-triv-io/commit/51d8f3ab0d5d9c9669ca55d3c3c83d2993b1cd40, https://github.com/ECS189E/project-w21-triv-io/commit/e2ee54fe09ee1ad2d01f7c9652ec7adff563f353
 * Note: the segue in the commit is purely for testing purpose and will (100 percent) not show up in the final product.
### Manprit Heer
* Page 4: UI: Winning Page/Game Stats
 * Page is in progress. Created a more solid wireframe of the Game Stats to go on top of existing wireframe by Jessica. Pages will be completed by tomorrow morning, before 02/19 meeting. 
 * Initiated Logo-Making process for app 
### Roberto Lozano
* UI/Authentication: Log-In Screen
	* Continued work on the login/authentication system.
	* Finished implementing Google Login/Authentication
	* Began and completed Facebook Login/Authentication
	* Beginning research on implementing Apple Login/Authentication
	* Link to commit: https://github.com/ECS189E/project-w21-triv-io/commit/ef6f2f1ec282e348c528b8aea67367855ad7a250
### Jessica Ma
* UI: Pick 3 Categories (Before Start of Game)
* This app screen displays the list of existing categories of trivia questions and allows the player to select a total of three categories to play from.
* Created an initial Game Model that interacts with the Category Selection View Controller as the user selects and deselects different categories from the list. The list of available categories is currently hard-coded inside the Game Model.
* Link to commit: https://github.com/ECS189E/project-w21-triv-io/commit/7e76402020e35dae3ae199226cc87027770fba8a
* Will work on creating trivia questions to be added to the app
