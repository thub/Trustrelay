require 'test_helper'

class JumpsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:jumps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_jump
    assert_difference('Jump.count') do
      post :create, :jump => { }
    end

    assert_redirected_to jump_path(assigns(:jump))
  end

  def test_should_show_jump
    get :show, :id => jumps(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => jumps(:one).id
    assert_response :success
  end

  def test_should_update_jump
    put :update, :id => jumps(:one).id, :jump => { }
    assert_redirected_to jump_path(assigns(:jump))
  end

  def test_should_destroy_jump
    assert_difference('Jump.count', -1) do
      delete :destroy, :id => jumps(:one).id
    end

    assert_redirected_to jumps_path
  end
end
