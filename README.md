# ForecastFetcher

A coding assessment for a Ruby on Rails role.

### Introduction

This is a fresh Rails 7.1 app using Ruby 3.2.2, with Tailwind sprinkled in for efficient styling. The approach with this application was to ensure that code is written like enterprise production code and to follow best practices when developing code.

This document will cover the basics of getting the application up and running (as any good README would), but will also function as an explainer about the application, it's requirements and other observations from the development process.

### Requirements

Here is a copy of the requirements I was given for this assignment:

```
Requirements:
  * Must be done in Ruby on Rails
  * Accept an address as input
  * Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
  * Display the requested forecast details to the user
  * Cache the forecast details for 30 minutes for all subsequent requests by zip codes.
  * Display indicator if result is pulled from cache.
Assumptions:
  * This project is open to interpretation
  * Functionality is a priority over form
  * If you get stuck, complete as much as you can
Submission:
  * Use a public source code repository (GitHub, etc) to store your code
  * Send us the link to your completed code
```

These requirements match a good balance of being specific enough but also leaving some intereptation up to the implementor. Initially the requirements seemed almost too simple, but the complexity was in the details. The application must accept an *address* as the input for fetching a forecast but also must cache the forecast details *by ZIP Code* for 30 minutes after the request is made. Interesting distinction between using the *address* as an input and caching *by ZIP Code*. Read on to see how I resolved this.

### Implementation

The majority of the implementation would be in interacting with the API service for getting the weather. To that end the first order of business was selecting a provider to interact with. After some testing, I landed on the [VisualCrossing Timeline Weather API](https://www.visualcrossing.com/resources/documentation/weather-api/timeline-weather-api/). This API helps by consolidating the forecast, current conditions, historical observations and other data into a single API. It also allows easy lookup of weather data for an address, partial address, city/state and ZIP Code. This API is free for a limited number of requests per month, but does require account setup.

The initial API implementation was simple enough, ensuring that the API client was passed the correct data and to handle any errors sent back from the API for the service being down or for the case where the user entered incorrect details.

Resolving the caching challenge was interesting, as the requirements didn't cover what needed to happen in the case that the user didn't enter a ZIP Code. My approach here was to simplify the address being passed to the API from the end user, I settled on a regular expression to capture the ZIP Code (if present) at the end of an address string. If there is a ZIP Code present, I use the ZIP Code both as the "address" for the weather service and the cache key. If there is no ZIP Code present, I assume the address is more generic (e.g. New York, New York or Portland, OR) and use that as the cache key instead of the ZIP Code.

This regular expression is admittedly naive and a more robust option would be implementing an address validation service to ensure the address that is entered is accurate. In my analysis of other "similar" sites, no address validation was used, the sites requested current location from the browser or allowed the end user to enter a ZIP Code or City/State combination. My conclusion was that address validation was too far out of scope for this assignment and opted to not implement it.

Caching and expiration was straightforward after determining which values to use as cache keys and how to handle addresses that did not include ZIP Codes. All code for the VisualCrossing API is consolidated into: `lib/visual_crossing_weather_client.rb` and has an accompanying spec file available here: `spec/lib/visual_crossing_weather_client_spec.rb`.

### Let's go!
Alrighty, enough talk about how I got to the end of the build and lets just run it!

### Prerequisites
  * Ruby 3.2.2 installed (I use `rbenv` and `ruby-build`)
  * API Key from [VisualCrossing](https://www.visualcrossing.com/weather-api)


### Getting Started
  1. Clone this repository into your local environment
  2. Copy `.env.example` to `.env` and fill in your API Key
  3. Run `bundle install`
  4. Run `rails dev:cache` - without running this command Rails will NOT cache while in development mode.
  5. Run `bin/dev` - this is the server process for the dev server, it also includes a Tailwind CSS server to handle updating of the CSS in dev mode.
  6. Visit [http://localhost:3000](http://localhost:3000) in your browser!

### API Key Considerations
I opted not to distribute my API key with the code in the repository as that is a best practice, however that forces anyone reviewing this application to sign up with VisualCrossing for an API Key. To mitigate any friction in the process I included a copy of my API Key in my email to notify the recruiter I was completed with the assignment. In a production environment, there should be better defined procedures for handling API keys. Some examples include: using Rails built in secret management, distributing the API keys to the environment with configuration management tooling.

### Data Modeling
This application ended up not needing much (if anything) in the way of data modeling as there is no persisted data with the current architecture. Based on the requirements I was able to craft a solution that didn't need to model and persist structured data in a database.

The persistence of the cached objects is handled entirely by the Rails framework.

The structure of the API response acted as a "schema", informing what data could be accessed and presented to the user.

### Production Ready?
If this was to be deployed as a production application, I would implement some sort of shared caching layer across the application servers. (e.g. Redis) The current cache implementation is limited to the memory of the application server it runs on. The code changes required to accomodate this would only be in changing the cache store that Rails uses, no application code would need to change.