
# Music Match

Music match is essentially a media library that allows users to select a certain song located in their iTunes music library or from a playlist in their spotify account and find the related videos for the song in YouTube with just one press of a button. Users are also able to save those videos to an existing playlist within their YouTube account or create new playlists.

# Motivation

The development of this application started as a need to easily search for and access songs and videos through a singular source. The application is meant to allow users full control and access to the major media sources including Itunes, Spotify and YouTube and integrate them with one another. In future revisions I plan to integrate google cast to allow users to cast found music videos easily onto their TV.

# Tech/framework used

* XCode 9.3.1 on IOS 11.3 using Swift
* Application was tested on an Iphone 6S
* Frameworks/ APIs used : GoogleAPIClientForREST/ YouTube, GoogleSignIn, youtube-ios-player-helper, Spotify Login, Spotify SDK

# Dependencies

CocoaPods using pod install to implement frameworks

'''
platform :ios, æ11.0'
use_frameworks!
workspace 'MusicMatchRev2'
target 'MusicMatchRev2' do
pod 'GoogleAPIClientForREST/YouTube'
pod 'Google/SignIn'
pod 'youtube-ios-player-helper', :git=>'https://github.com/youtube/youtube-ios-player-helper', :commit=>'head'
pod 'SpotifyLogin', '~> 0.1'
end
'''

# Building/Running

1. Open Project Folder and click on MusicMatchRev2.xcworkspace to open project.
2. Build and run app on a target device.

*Application must be built on a physical iphone device with an iTunes Library in order to use the æMy Music Library FeatureÆ*

# How to use?

## Searching for a video

1. Open Music Match App.
 
2. To search using your music library, click on æMy Music LibraryÆ or click on æSpotify PlaylistsÆ on the tab bar below. 

*Spotify Playlists requires logging in to view user playlists. 
*My Music Library requires permission granted.
 
3. In the My Music Library or Spotify Playlists page just select a song youÆd like to search for and it opens up a YouTube Search Results Page showing related videos.


## Adding Videos to liked Videos

When in YouTube Search Results Page Double Click on a video to add it to your liked videos.

## Deleting Videos from liked Videos

When in Liked Videos View, swipe left on a video to bring up Delete option and hit Delete when notification pops up.

## Adding Videos to a YouTube Playlist

When in YouTube Search Results Page, swipe left on a video to add it to one of your existing YouTube playlists or create a new playlist.

*Accessing YouTube Playlists requires logging into your Google or YouTube account. Must also grant permission to the application to access YouTube account information.



