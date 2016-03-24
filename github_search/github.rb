require 'rest-client'
require 'byebug'

# utilize enumerator
# for each name, it would make a request
# for each request, it would process results
#   processing results may need to pageniate
def search_github_repos(search_names, language, output_file_name)
  search_names.each do |name|
    # get results for first page
    response = query_api(name, language, 1)

    # figure out how many pages exist
    last_page = results_last_page(response[:headers])

    # process first page
    # response[:results] is JSON object
    # method is responsible for writing repo data to csv
    process_page_results(output_file_name, response[:results]['items'])

    # process results for each successive page
    (2..last_page).each do |page|
      # query api for results for the specified page
      response = query_api(name, page)

      # process results from the page
      # response[:results] is JSON object
      # method is responsible for writing repo data to csv
      process_page_results(output_file_name, response[:results]['items'])
    end
  end
end

def output_file(file_name)
  # 'a+' write mode appends data to end of the file
  File.new(file_name, 'a+')
end

def repo_names_enumerator(length)
  # array of letters a-z
  # alphabet = ('a'..'z').to_a
  # return enumerator
  # alphabet.repeated_permutation(length)
  ['aaa', 'aab']
end

# return query string for github's search api
def query_string(name, language, page)
  "https://api.github.com/search/repositories?q=#{name}+language:#{language}&page=#{page}&per_page=100"
end

# returns hash
# {
#   headers: {},
#   results: {}
# }
def query_api(name, page)
  begin
    response = RestClient.get(query_string(name, page))
  rescue
    # assume if exception is raised, encountered the rate limit
    # wait for a bit and try again
    sleep(60)
    response = RestClient.get(query_string(name, page))
  end

  {
    headers: response.headers,
    results: JSON.parse(response)
  }
end

def results_last_page(headers)
  max = 0

  # reults page info returns array of page numbers
  # last page will be largest value in list
  result_page_info(headers).each { |item| max = item if item > max }

  max
end

# 3 cases
# first page - next, last
# somewhere in the middle - first, prev, next, last
# last page - first, prev
# [ int, int, int, int ]
def result_page_info(headers)
  link = headers[:link]

  return [] if link.nil?

  page_strings = link.split('page=')

  pages = []

  page_strings.each_with_index do |item, index|
    next if index == 0

    pages << item.to_i
  end

  pages
end

# iterate through results
# append repo data to the csv file
def process_page_results(output_file_name, result_items)
  file = output_file(output_file_name)

  result_items.each do |result|
    file.write("#{result['id']},#{result['full_name']},#{result['language']}\n")
  end
end

search_github_repos(repo_names_enumerator(3), 'C', 'repo_metadata.csv')
search_github_repos(repo_names_enumerator(3), 'CPP', 'repo_metadata.csv')
