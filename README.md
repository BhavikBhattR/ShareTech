# ShareTech
project responsible for creating ios app that will allow people to learn about specific technologies and to share their knowledge via network provided by an app

## Things taken care while creating this project

###### To store user's data/media, FirebaseAuth(To Authenticate), FirebaseFirestore(To store data) and FirebaseStorage(To store files) are used. But when user deletes his/her account, it was taken care that user is not removed only from FirebaseAuth or FirebaseFirestore but with account deletion FirebaseStorage must be clear by dumping that user's data.
###### App's purpose was to deliever latest tech knowledge but in a way user wants to. So the data of post stored by user was structured in a way that, it's retrieval gets easier and effective when user fiters the posts using technologies tags. So with the simple idea of having tags of technologies with every post's data, makes a attractive feature. 
###### App has several features ex. Chat feature, Personal feed and Posts feed. But each of the module was created seperately first and to integrate them in a way that none of the module fails to act as it was acting differently. Every minor detail was changed considering it's impact on each module.
###### App uses the firestore as database and when user is currently using the app, it is obvious we want to get user feed/screen updated with the change in database by other user and for that it was needed to use snapshot listeners and it is necessary that we use snapshot listener in a manner that they are listening only when it is needed. Ex. In chat page, when user is chatting, at that specific time only we need to run the snapshot listener but once user get out of the screen, it is always good to remove the snapshot listener for firestore database.


 ###### When app launchs, first screen displays the technologies name, user can filter the posts on the basis of technologies they are interested in.

![InitialScreen](https://user-images.githubusercontent.com/68719677/218311523-3db2245d-f9b1-45e3-a325-4c5730763ee4.gif)

###### Users can add their like if they liked the post by doing right swipe on the card holding that post.

![RightSwipe](https://user-images.githubusercontent.com/68719677/218311755-46520dbb-bf59-49e3-b56d-5ccf7f56f406.gif)

###### Users can add their ignorance if they did not like the post much by doing left swipe on the card holding that post

![LeftSwipe](https://user-images.githubusercontent.com/68719677/218311837-42fc0891-1aee-4f23-9d6f-9a912e5ba96d.gif)

###### User can create new post by adding the title and contents of the post by tagging their content with technology names, they can post multiple images with it also.

![_CreateNewPost](https://user-images.githubusercontent.com/68719677/218312106-b08b6404-355f-470d-913c-b6cafe6d675d.gif)

###### User can chat with other use of the system.

![Chat-Feature](https://user-images.githubusercontent.com/68719677/218312131-c1fa7431-0bbc-46a7-834c-3ff3fb4e45d4.gif)

###### User can see their own posts in the personal section.

![PersonalSection](https://user-images.githubusercontent.com/68719677/218312170-716f9752-0ee0-44f7-955b-cce8cd8ad540.gif)

###### If User liked someone's post they can go to their profile by searching their username.

![UserSearch](https://user-images.githubusercontent.com/68719677/218312191-99dfefd8-4350-459f-a5ca-d72ac3213739.gif)


