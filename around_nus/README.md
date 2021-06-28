# AroundNUS: The fastest way to get around NUS

## Proposed Level of Achievement

Apollo 11

## TechStack

<img src="./README_images/techstack.PNG"> 


## Motivation

NUS students, including us, often find themselves having to use various platforms in the process of trying to get from one place to another in school. From using NUS Next Bus to first determine the bus to bring them to the nearest bus stop, then using google maps to find a way to walk to the building from the bus stop to the destination building. If they are unsure of the location of the room / lecture theatre, NUSMODS will then be employed to figure out where the room is before the student can get there. This is an extremely time consuming and inefficient process which we aim to solve through our app.

## Scope of Project

Our app thus aims to provide an all in one user - friendly navigation app for NUS students to find their way around campus efficiently without having to cross - reference from different apps or websites, with the 4 core features below.

<img src="./README_images/AroundNUS_Features.PNG">  

The navigation screen will provide a map interface using the Google Maps API for users to pinpoint their current location, as well as a search feature that will allow them to locate places and amenities in NUS, along with information about the place (eg. accessibility, opening hours, general crowd level etc.)

The bus screen using the NUS Next Bus API will provide bus timings of busses that are available at the bus stop they are currently at, as well as pick up points of all bus routes available.

Finally, the most important directions feature which requires the Google Maps Routing API, together with NUS Next Bus API for bus routes, will allow users to input their starting and ending location and the app will provide detailed directions on the shortest path to get there.

## App Prototype

# Home Page

Current Features:

Users are able to interact with Google Maps interface with standard google maps functions such as zoom, scroll and set markers on tap. 
Users are able to find and set a marker on their current location on the map by tapping the set location button at the bottom of the screen.
Users are able to use search bar to search locations of places in NUS, both places shown in google maps (eg. Utown, EA, Central Library) as well as specific lecture theatres and tutorial rooms. A marker will automatically appear on the searched location.

<img src="./README_images/Home_Page_Marker.PNG">
<img src='./README_images/Home_Page_Search_DropDown.PNG">

Milestone III Improvements:

Searching for a location in the search bar will display information about that location

# Bus Timings Page

Current Features:

Users are able to get arrival timings of all bus routes that are available at any bus stop around NUS by clicking on it.
Users are able to search for a bus stop using the search bar.

<img src="./README_images/BusTimings_Page_Default.PNG">
<img src="./README_images/BusTimings_Page_Search_DropDown.PNG">

Milestone III Improvements:

On top of showing bus timings of all bus routes at all available bus stops, a separate tab will be included to allow users to see all the pick up points of all shuttle routes available in NUS.

# Directions Page

Current Features:

Users are able to interact with google maps interface. (similar to main screen)
Users are able to input a starting location and a destination location. A blue and red marker will appear automatically on the respective locations upon input.
After entering both start and destination locations, users can obtain the optimal shortest path between both locations.
Three modes of travel will be charted out for the user; driving, walking and finally via NUS shuttle busses. Users can select each of the 3 routes to be displayed on the map.
Users can click on the Directions button to get directions for the NUS shuttle bus mode of travel.

<img src="./README_images/Directions_Page_Search.PNG">
<img src="./README_images/Directions_Page_Directions_Display.PNG">

Milestone III Improvements:

Adjust route for walking to and from bus stops being displayed; google maps shows only walking paths on roads.
Pre-Process some of the information to reduce route calculation time.
Users able to save recent and frequently travelled / favourite destinations in Directions Screen
Backend database allowing users to save favourite / frequently travelled locations 
Backend database storing recent entries input by user
Provide second and third alternatives for paths that users can consider. In case of rain, suggest sheltered alternatives as well. 

## Problems Encountered

Below are the main problems, technical and non-technical, we faced during the prototyping phase of our app after Milestone I.

# Autocomplete search bar including NUS LTs and Tutorial Rooms (Solved)

As most places in NUS, especially lecture theatres and tutorial rooms, are not shown on google maps, integrating these places into the search bars in both the Home Page as well as the Directions Page was a challenge. 

For places already available inside Google Maps, the autocomplete feature was slightly more straightforward as the data was being returned from Google in the correct format. However, as the json file of information returned from the NUSMODs http server was not in the correct format, we had to use a script to fetch the relevant information from the server before storing it in a suitable format json file to be parsed by the Google Autocomplete API.

# Importing NUS Next Bus API for bus route information (Solved)

For our app to function as a navigation app, we had to integrate the bus stops and bus services info into our app as an API. However, we were told that it would be hard to get permission to use the official NUS Buses API. 

Thus, we had to use the unofficial API wrapper online [https://suibianp.github.io/nus-nextbus-new-api/#/] , where we could get the information we needed by fetching a json file from the http server and parsing it.

# Path Finding Algorithm suggesting shortest Bus Route to take (Needs Refinement)

As the NUS Shuttle Busses and Bus Stops are not taken into consideration when calculating the fastest route from one location to another in NUS, we had to come up with our own algorithm to determine what is the quickest way between 2 locations in NUS. This was a challenge as there were many corner cases we had to account for to return an accurate shortest path for the users to take.

As of now, our current algorithm finds the nearby bus stops of both the start and end location (within 200m) and finds the shortest direct shuttle bus route between those 2 bus stops the user can take. For now, we assume that the time between each stop for all bus routes are approximately the same, and thus, the lesser the number of bus stops between the start and end bus stop of a route, the faster the route will be.

This algorithm will be further improved to take into account factors such as arrival time of a bus as well as the exact distance of the bus route between start and end bus stops.

## System Testing

On top of carrying out extensive testing on our part, we also distributed the built apk of our app to some of our peers for them to experiment with our prototype. Below are the common bugs that our testers found along with additional features they wished to see in the app. 

All of these will be taken into account and remedied or added into the app for Milestone III as stated in the App Prototypes Section.

# Bugs

Slight lag when inputting addresses in Home Page and Directions Page.
Walking route to CENLIB and Information Technology Bus Stop (COMCEN) from Central Library inaccurate; states that the user should only walk on the road available in Google Maps.
‘Search Location’ hint text does not show up initially in the Home Page search bar; shows up after typing and clearing text in the search bar once.

# Additional Features

Display all bus routes in NUS plus pick up points of each route.
Display information of location on search in the Home Page.
Multiple Path options for Directions Page.
Sheltered Path option for Directions page.

# Miscellaneous Feedback / Suggestions

App does not have its own logo.
The UI of the app can be polished further.
Current Location button in the Home Page can be made more prominent.
Need to manually grant location permissions to use the current location button / feature.
After pressing the ‘Show Route’ button, it takes quite a while to load routes and directions.


## Program Flow
<img src="./README_images/ProgramFlow.PNG"> 
