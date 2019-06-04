ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.txt"
    assert_includes last_response.body, "changes.txt"
    assert_includes last_response.body, "history.txt"
    assert_includes last_response.body, "example.md"
  end

  def test_view_txt_file
    get "/about.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_equal "i am about file\n", last_response.body
  end

  def test_view_md_file
    get "/example.md"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<code>example code</code>"
  end

  def test_document_not_found
    get "/notafile.ext" # Attempt to access a nonexistent file
  
    assert_equal 302, last_response.status # Assert that the user was redirected
  
    get last_response["Location"] # Request the page that the user was redirected to
  
    assert_equal 200, last_response.status
    assert_includes last_response.body, "notafile.ext does not exist"
  
    get "/" # Reload the page
    refute_includes last_response.body, "notafile.ext does not exist" # Assert that our message has been removed
  end

  def test_editing_file
    get "/changes.txt/edit"
    assert_includes last_response.body, "<button type=\"submit\">Save Changes</button>"
  end

  def test_update_file
    post "/changes.txt", new_content: "new content"

    assert_equal 302, last_response.status
    get last_response["Location"]

    assert_includes last_response.body, "changes.txt has been updated"

    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end
end