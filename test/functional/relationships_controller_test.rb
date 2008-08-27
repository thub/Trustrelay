require File.dirname(__FILE__) + '/../test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:relationships)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_relationship
    assert_difference('Relationship.count') do
      post :create, :relationship => { }
    end

    assert_redirected_to relationship_path(assigns(:relationship))
  end

  def test_should_show_relationship
    get :show, :id => relationships(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => relationships(:one).id
    assert_response :success
  end

  def test_should_update_relationship
    put :update, :id => relationships(:one).id, :relationship => { }
    assert_redirected_to relationship_path(assigns(:relationship))
  end

  def test_should_destroy_relationship
    assert_difference('Relationship.count', -1) do
      delete :destroy, :id => relationships(:one).id
    end

    assert_redirected_to relationships_path
  end
end
