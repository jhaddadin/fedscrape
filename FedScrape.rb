require 'rubygems'
require 'nokogiri'
require 'csv'
require 'open-uri'
require 'date'
require 'fileutils'
require 'mail'
require 'google_drive'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

$towns = ["Abington", "Acton", "Acushnet", "Adams", "Agawam", "Alford", "Amesbury", "Amherst", "Andover", "Aquinnah", "Arlington", "Ashburnham", "Ashby", "Ashfield", "Ashland", "Athol", "Attleboro", "Auburn", "Avon", "Ayer", "Barnstable", "Barre", "Becket", "Bedford", "Belchertown", "Bellingham", "Belmont", "Berkley", "Berlin", "Bernardston", "Beverly", "Billerica", "Blackstone", "Blandford", "Bolton", "Bourne", "Boxborough", "Boxford", "Boylston", "Braintree", "Brewster", "Bridgewater", "Brimfield", "Brockton", "Brookfield", "Brookline", "Buckland", "Burlington", "Cambridge", "Canton", "Carlisle", "Carver", "Charlemont", "Charlton", "Chatham", "Chelmsford", "Chelsea", "Cheshire", "Chester", "Chesterfield", "Chicopee", "Chilmark", "Clarksburg", "Clinton", "Cohasset", "Colrain", "Concord", "Conway", "Cummington", "Dalton", "Danvers", "Dartmouth", "Dedham", "Deerfield", "Dennis", "Dighton", "Douglas", "Dover", "Dracut", "Dudley", "Dunstable", "Duxbury", "East Bridgewater", "East Brookfield", "East Longmeadow", "Eastham", "Easthampton", "Easton", "Edgartown", "Egremont", "Erving", "Essex", "Everett", "Fairhaven", "Fall River", "Falmouth", "Fitchburg", "Florida", "Foxborough", "Framingham", "Franklin", "Freetown", "Gardner", "Georgetown", "Gill", "Gloucester", "Goshen", "Gosnold", "Grafton", "Granby", "Granville", "Great Barrington", "Greenfield", "Groton", "Groveland", "Hadley", "Halifax", "Hamilton", "Hampden", "Hancock", "Hanover", "Hanson", "Hardwick", "Harvard", "Harwich", "Hatfield", "Haverhill", "Hawley", "Heath", "Hingham", "Hinsdale", "Holbrook", "Holden", "Holland", "Holliston", "Holyoke", "Hopedale", "Hopkinton", "Hubbardston", "Hudson", "Hull", "Huntington", "Ipswich", "Kingston", "Lakeville", "Lancaster", "Lanesborough", "Lawrence", "Lee", "Leicester", "Lenox", "Leominster", "Leverett", "Lexington", "Leyden", "Lincoln", "Littleton", "Longmeadow", "Lowell", "Ludlow", "Lunenburg", "Lynn", "Lynnfield", "Malden", "Manchester-by-the-Sea", "Mansfield", "Marblehead", "Marion", "Marlborough", "Marshfield", "Mashpee", "Mattapoisett", "Maynard", "Medfield", "Medford", "Medway", "Melrose", "Mendon", "Merrimac", "Methuen", "Middleborough", "Middlefield", "Middleton", "Milford", "Millbury", "Millis", "Millville", "Milton", "Monroe", "Monson", "Montague", "Monterey", "Montgomery", "Mount Washington", "Nahant", "Nantucket", "Natick", "Needham", "New Ashford", "New Bedford", "New Braintree", "New Marlborough", "New Salem", "Newbury", "Newburyport", "Newton", "Norfolk", "North Adams", "North Andover", "North Attleborough", "North Brookfield", "North Reading", "Northampton", "Northborough", "Northbridge", "Northfield", "Norton", "Norwell", "Norwood", "Oak Bluffs", "Oakham", "Orange", "Orleans", "Otis", "Oxford", "Palmer", "Paxton", "Peabody", "Pelham", "Pembroke", "Pepperell", "Peru", "Petersham", "Phillipston", "Pittsfield", "Plainfield", "Plainville", "Plymouth", "Plympton", "Princeton", "Provincetown", "Quincy", "Randolph", "Raynham", "Reading", "Rehoboth", "Revere", "Richmond", "Rochester", "Rockland", "Rockport", "Rowe", "Rowley", "Royalston", "Russell", "Rutland", "Salem", "Salisbury", "Sandisfield", "Sandwich", "Saugus", "Savoy", "Scituate", "Seekonk", "Sharon", "Sheffield", "Shelburne", "Sherborn", "Shirley", "Shrewsbury", "Shutesbury", "Somerset", "Somerville", "South Hadley", "Southampton", "Southborough", "Southbridge", "Southwick", "Spencer", "Springfield", "Sterling", "Stockbridge", "Stoneham", "Stoughton", "Stow", "Sturbridge", "Sudbury", "Sunderland", "Sutton", "Swampscott", "Swansea", "Taunton", "Templeton", "Tewksbury", "Tisbury", "Tolland", "Topsfield", "Townsend", "Truro", "Tyngsborough", "Tyringham", "Upton", "Uxbridge", "Wakefield", "Wales", "Walpole", "Waltham", "Ware", "Wareham", "Warren", "Warwick", "Washington", "Watertown", "Wayland", "Webster", "Wellesley", "Wellfleet", "Wendell", "Wenham", "West Boylston", "West Bridgewater", "West Brookfield", "West Newbury", "West Springfield", "West Stockbridge", "West Tisbury", "Westborough", "Westfield", "Westford", "Westhampton", "Westminster", "Weston", "Westport", "Westwood", "Weymouth", "Whately", "Whitman", "Wilbraham", "Williamsburg", "Williamstown", "Wilmington", "Winchendon", "Winchester", "Windsor", "Winthrop", "Woburn", "Worcester", "Worthington", "Wrentham", "Yarmouth"]
$townsAndSubscribers = {}

# Set a default email address to receive all alerts unless a list of email addresses is provided
$towns.each{|town| $townsAndSubscribers["#{town}"] = "jhaddadin@myemailaddress.com"}

# Describe list of email addresses to receive alerts for certain cities and towns
# METROWEST DAILY NEWS
$townsAndSubscribers["Framingham"] = ""
$townsAndSubscribers["Ashland"] = ""
$townsAndSubscribers["Sudbury"] = ""

# MILFORD DAILY NEWS
$townsAndSubscribers["Milford"] = ""
$townsAndSubscribers["Medfield"] = ""

# PATRIOT LEDGER
$townsAndSubscribers["Braintree"] = ""
$townsAndSubscribers["Canton"] = ""
$townsAndSubscribers["Carver"] = ""

# FALL RIVER
$townsAndSubscribers["Fall River"] = ""

# TAUNTON GAZETTE
$townsAndSubscribers["Taunton"] = ""

# Set email settings, specific to location where script is deployed.
Mail.defaults do
  delivery_method :smtp, address: "address.relay.com", port: XX
end

$docketentries = []

def casesearch(term, email)
matchingcases = []

$docketentries.each {|subarray|
  subarray.each {|string|
      if string =~ /#{term}/
        matchingcases.insert(-1, subarray)
      end
    }
  }

if matchingcases != []
matchingcases.map! do |subarray|
  "<b>#{subarray[1]}</b><br>Docket: <a href=\"#{subarray[2]}\">#{subarray[0]}</a><br>#{subarray[3]}<br>Filed on #{subarray[5]}<br><br>"
end

matchingcases << "<br><br>======================<br><br><i>This email was generated by a computer in the office of the MetroWest Daily News. The computer searches records filed at the U.S. District Court. Questions? Comments? Email Jim Haddadin at <b>jhaddadin@wickedlocal.com</b> or call him at <b>617-863-7144</b>.</i>"

mailalert = Mail.new do
  from   "CourtAlerts@wickedlocal.com"
  to     email
  subject "[U.S. District Court] #{term}"
  html_part do
    content_type 'text/html; charset=UTF-8'
    body matchingcases
  end
end
mailalert.deliver
end
end

rssfeed = Nokogiri::XML(open("https://ecf.mad.uscourts.gov/cgi-bin/rss_outside.pl"))
puts "Retrieved the RSS feed! Nice work!"


rss_times = if File.exists?('rss_times')
  Marshal.load( File.read('rss_times') )
else
  Hash.new( Time.mktime('1970') )
end

puts "Loaded/created the RSS times file. You're doing great!"

rssfeed.css('item').reverse.each do |item|
  @title = item.css('title').text.split(' ', 2)
  @link = item.css('link').text
  @description = item.css('description').text
  @guid = item.css('guid').text
  @pubDate = Time.parse(item.css('pubDate').text)
  @humandate = @pubDate.strftime("%A, %b %e at %I:%M %P")
  @itemarray = [@title, @link, @description, @guid, @humandate].flatten

  if @pubDate > rss_times['timeofpost']
  $docketentries << @itemarray
  rss_times['timeofpost'] = @pubDate
  end
end

File.open( 'rss_times', 'w' ) do|f|
    f.write Marshal.dump(rss_times)
    end

# Scan the RSS feed for cases that match search terms
# Email alerts to subscribers for each term
$townsAndSubscribers.each {|town, subscribers|
	puts "Searching for cases that match the term #{town}"
	casesearch("#{town}", "#{subscribers}")
	}

digest = $docketentries.map! do |subarray|
  "<b>#{subarray[1]}</b> (<a href=\"#{subarray[2]}\">Docket</a>)<br>#{subarray[3]}<br><br>"
end

digest << "<br><br>======================<br><br><i>This email was generated by a computer in the office of the MetroWest Daily News. The computer searches records filed in U.S. District Court. Questions? Comments? Email Jim Haddadin at <b>jhaddadin@wickedlocal.com</b> or call him at <b>617-863-7144</b>.</i>"

# Email a digest of all new filings since the last search
mailalert = Mail.new do
  from   "CourtAlerts@wickedlocal.com"
  to     "jhaddadin@wickedlocal.com"
  subject "[U.S. District Court] RSS Digest"
  html_part do
    content_type 'text/html; charset=UTF-8'
    body digest
  end
end

mailalert.deliver
