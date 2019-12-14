# Photo Gallery App

<img src="/SCREENSHOT.gif" width="20%">

## About

An iOS application for viewing pictures from Unsplash. It contains two screens: gallery and full screen viewer.
Gallery shows infinite feed of puctures downloaded from the web server on user scroll.
Full screen viewer show an author of a picture and allow users to interact with the pucture by zooming and swiping it.

## UI and UX

App was developed with a user in mind. It has good looking interface with custom collection view layout, gesture recognizers for rich interactions and intuitive custom transitions from one screen to another.

## Architecture

Project has standard MVC architecture with separation code base into presentational and model layers. 
Presentation part uses models and services via interafaces and knows nothing about real implementation. 
Model layer consists of business logic and data structures. It has no clue how photos might be presented and  it can be used with any presentation.

## Contribution

Fell free to make a pull request if you find some bug or have an improvement.


