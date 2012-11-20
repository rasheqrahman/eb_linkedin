# EB_Linkedin 

This small ruby program uses the Eventbrite and LinkedIn APIs to pull in LinkedIn profile data for Eventbrite registrants. 

## Getting Started - Registering with Linkedin and Eventbrite


#### LinkedIn API


In order to access the Linkedin API, you'll need to get an API key. To do so you have to create a LinkedIn app by visiting (https://www.linkedin.com/secure/developer) and registering your "app". Once you've registered you will be assigned an "API Key" and a Secret Key. See below for an example.

(https://github.com/rasheqrahman/eb_linkedin/blob/master/linkedin_secret_key.png)

Be sure to enter the API key in the field marked "api_key" and the Secret Key in the field marked "api_secret" in the file entitled linkedin.authorization.rb.

Once you've update the api_key and api_secret you can run the file -> linkedin.authorization.rb in a command line program like Mac OSX Terminal.

When the file runs, you'll be prompted to copy a custom URL into your browser. This URL will take you to the LinkedIn OAuth tool where you'll enter your Linkedin username/password. Once authenticated, you'll be given a numeric code (pin number) to enter in the command line, this will return a set of four variables which you should cut and paste into the top of the config.yml file. These variables are:

``` ruby
api_key: 
api_secret: 
api_token_authorized: 
api_secret_authorized: 
```

While you're in the config.yml file you should edit the 'file_prefix' variable. This variable is used to name the pdf and html files that are generated when the main eb-linkedin.rb program is run. I've put a name that I use when I run the script for your reference.

Finally, you'll want to decide which fields to pull from the LinkedinAPI. The list of fields is at (https://developer.linkedin.com/documents/profile-fields). Remember in many cases you'll be pulling fields from people you are not directly connected to so you'll be limited to pulling only data that is in the LinkedIn Public profile (the profile you can see without being connected to an individual.) I've included the fields I use in the eb-linkedin.rb file but any valid field should work.

#### Eventbrite API


To use the Eventbrite API, you also have to register your "App" at (https://www.eventbrite.com/api/key). Once you've registered you'll be assigned an app_key. You should enter this in the field called "eb_app_key" in the config.yml file. You should also retrieve your "user_key" by visiting (https://www.eventbrite.com/userkeyapi/). You should enter the user key in the field "eb_user_key" in the config.yml file. 

Finally you'll need to enter the event ID. You can look up your event id by clickin on the event name. If you look at the URL of the event in your address bar, you'll see that the URL ends with '?eid=<number>'. The number at the end is your Event ID number and it should entered in config.yml as eb_event_id.
	
#### Eventbrite setup


While the eb-linkedin.rb program uses mainly standard Eventbrite fields, in order to pull in the Linkedin data, you will have to create a registration question asking for the user's bio/Linkedin public profile URL. In the eb-linkedin.rb program, this field is the second question asked hence the index in line 41 is 1.
	
#### Running the EB-LinkedIn Program


Once all of the relevant api keys and fields have been added to config.yml, you can run the eb-linkedin.rb program to create the html and pdf files that contain the LinkedIn and Eventbrite profile information.	

To run the program type 

``` ruby
ruby eb-linkedin.rb
```

#### Questions?

If you have questions about this script, please don't hesitate to email me at rasheqrahman [dot] tygrlabs [dot] com.
