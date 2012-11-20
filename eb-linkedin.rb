# /Users/rasheqrahman/.rvm/rubies/ruby-1.9.3-p194/bin/ruby

# load relevant gems
require 'rubygems' 
require 'linkedin' 
require 'markaby'
require 'pdfkit'
require 'yajl'
require 'eventbrite-client'
require 'yaml'

# load config variables from config.yml. Helps keep the code tidy!
APP_CONFIG = YAML.load_file("config.yml")

# Profile fields from https://developer.linkedin.com/documents/profile-fields
LinkedIn.default_profile_fields = APP_CONFIG['LinkedIn_profile_fields']

# Output files (html, pdf)
output_file_name = APP_CONFIG['file_prefix'] + ".html"
pdf_file_name = APP_CONFIG['file_prefix'] + ".pdf"

# Establish a connection to the LinkedIn API
client = LinkedIn::Client.new(APP_CONFIG['api_key'], APP_CONFIG['api_secret'])

# Use the api authorised values to gain access to the LinkedIn API
client.authorize_from_access(APP_CONFIG['api_token_authorized'], APP_CONFIG['api_secret_authorized'])

# Connect to the EventBrite API
eb_auth_tokens = { app_key: APP_CONFIG['eb_app_key'],
                   user_key: APP_CONFIG['eb_user_key'] }
eb_client = EventbriteClient.new(eb_auth_tokens)

# Load all the attendees for a single event specified in config.yml
attendee_list = Hash.new
response = eb_client.event_list_attendees(id: APP_CONFIG['eb_event_id'])
attendees = response["attendees"]
attendees.each do |attendee| # Load a single attendee's data
  attendee = attendee["attendee"] # JSON structure requires you to index each attendee with "attendee" 
  first_name = attendee["first_name"] # Attendee's First Name - default Eventbrite field
  last_name = attendee["last_name"] # Attendee's Last Name - default Eventbrite field
  bio = attendee["answers"][1]["answer"]["answer_text"] # Attendee's Bio - I used an Evenbrite registration 'question' field to store the attendee's bio. I gave users an option to provide text bio or link to public LinkedInP profile URL. Eventbrite's JSON feed provides the values as "Answers"
  title = attendee["job_title"] # Attendee's Job Title - default Eventbrite field
  company = attendee["company"] # Attendee's Company - default Eventbrite field
  if bio.include? ('linkedin.com') # Check if user provided a public LinkedIn Profile URL
    url = bio # If bio is a LinkedIn public profile URL, assign URL to LinkedIn Profile URL and set to bio field to ""
    bio = ""
  else
    url = "" # If bio is NOT a LinkedIn public profile URL, assign URL to LinkedIn Profile URL
  end
  attendee_key = first_name + last_name # Create an Attendee Key for each attendee's data that is a concatenation of the attendee's first and last name.
  attendee_key = attendee_key.gsub(/\s+/, "").to_sym # Remove all spaces in the Attendee Key and convert it to a symbol 
  attendee_list[attendee_key] = {:first_name => first_name, :last_name => last_name, :url => url, :bio => bio, :title => title, :company => company} 
end

# Use Markaby gem to build the HTML web page where the Linkedin Profile information wil be displayed
mab = Markaby::Builder.new
mab.html do
  head { 
    title "LinkedIn Profiles"
    link "rel" => "stylesheet", "href" => 'stylesheets/foundation.min.css' # Use foundation framework for css  
    link "rel" => "stylesheet", "href" => 'stylesheets/app.css'
  }
  body do
    div.row do
      div :class => "twelve columns" do
        h1 "Attendee Profile Information"
      end
      hr
    end
    sorted_attendee_list = attendee_list.sort_by { |k, v| v[:last_name] } # Sort attendee list hash by last name
    sorted_attendee_list.each do |attendee| # Access a single attendee
        attendee = attendee[1] # Pick up the attendee's data
        if attendee[:url] != "" # If the attendee's URL is not empty, use its URL as the public LinkedIn profile URL in the LinkedIn API 
          linkedin_url = attendee[:url].strip
          if linkedin_url.start_with?('www') # People often cut and paste their public Linkedin profile URLs from their LinkedIn profile pages. These cut and paste URLs start with www but LinkedIn API requires URLs to start with 'http://', so this code creates a 'http' URL. 
            linkedin_url = "http://" + linkedin_url
          end
          user_profile = client.profile(:url => linkedin_url)
          unless (user_profile.positions.nil? || user_profile.positions.total.zero?) 
            titles = user_profile.positions.all.map{|t| t.title} # Retrieve the current title of the LinkedIn profile from a collection of positions
            companies = user_profile.positions.all.map{|c| c.company } # Retrieve the current company (organization) of the LinkedIn profile from a collection of positions
          end 
          if user_profile.picture_url? #If the LinkedIn Profile has picture, retrieve the URL and the associated picture  
            div.row do
              div :class => "two columns" do
                a.th do
                  img "src" => user_profile.picture_url
                end
              end
            end
          end
        end
        div.row do
          div :class => "twelve colunns" do
            h2 attendee[:first_name] + " " + attendee[:last_name] # Print the first and last name of the Attendee using data from the Eventbrite registration
            if attendee[:title].to_s.strip != "" && attendee[:company].to_s.strip != "" # Pull out the title and company name from the Eventbrite registration. If they are not blank, then print them out.
              h3.subheader do
                " #{attendee[:title]} at #{attendee[:company]}"            
              end
            else
              if titles and companies # If the Eventbrite title and company fields are blank, try retrieving the information from the LinkedIn profile.
                h3.subheader do
                  titles.first + " at " + companies.first.name
                end                   
              end
            end
            if attendee[:bio] != "" # If the Eventbrite bio is not a LinkedIn profile URL, then retrieve the bio entered into the EventBrite registration
              p attendee[:bio]
            else
              p user_profile.summary # If the Eventbrite bio is not a LinkedIn profile URL, then retrieve the LinkedIn profile summary data
              a linkedin_url, "href" => linkedin_url  
            end
          end
          hr
      end
    end
  end
end
                
File.open(output_file_name, 'w') { |file| file.write(mab.to_s) } # create the HTML file with all of the retrieved LinkedIn profiles. I do this as a backup so I can post the HTML file online as well.

kit = PDFKit.new(mab.to_s, :page_size => 'Letter') # create a letter-sized PDF file
kit.stylesheets << 'stylesheets/foundation.min.css' # use the Zurb Foundation css for formatting
file = kit.to_file(pdf_file_name)
