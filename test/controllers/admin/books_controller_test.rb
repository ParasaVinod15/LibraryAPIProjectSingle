require "test_helper"

class Admin::BooksControllerTest < ActionDispatch::IntegrationTest
  test "should get upload_form" do
    get admin_books_upload_form_url
    assert_response :success
  end

  test "should get upload" do
    get admin_books_upload_url
    assert_response :success
  end
end
